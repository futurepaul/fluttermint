//! Minimint client with simpler types
use anyhow::anyhow;
use bitcoin::hashes::sha256;
use fedimint_api::{
    db::{Database, DatabaseKeyPrefixConst},
    encoding::{Decodable, Encodable},
};
use fedimint_core::config::ClientConfig;
use fedimint_core::modules::ln::contracts::ContractId;
use futures::{stream::FuturesUnordered, StreamExt};
use lightning_invoice::{Invoice, InvoiceDescription};
use mint_client::api::WsFederationConnect;
use mint_client::{api::WsFederationApi, UserClient, UserClientConfig};

use crate::{
    api::BridgeInvoice,
    payments::{Payment, PaymentDirection, PaymentKey, PaymentKeyPrefix, PaymentStatus},
};

pub struct Client {
    pub(crate) client: UserClient,
}

#[derive(Clone, Debug, Encodable, Decodable)]
pub enum ConnectionStatus {
    NotConfigured,
    NotConnected,
    Connected,
}

impl Client {
    pub fn fetch_payment(&self, payment_hash: &sha256::Hash) -> Option<Payment> {
        self.client
            .db()
            .get_value(&PaymentKey(payment_hash.clone()))
            .expect("Db error")
    }

    pub fn list_payments(&self) -> Vec<Payment> {
        self.client
            .db()
            .find_by_prefix(&PaymentKeyPrefix)
            .map(|res| res.expect("Db error").1)
            .collect()
    }

    pub fn save_payment(&self, payment: &Payment) {
        self.client
            .db()
            .insert_entry(&PaymentKey(payment.invoice.payment_hash().clone()), payment)
            .expect("Db error");
    }

    pub fn update_payment_status(&self, payment_hash: &sha256::Hash, status: PaymentStatus) {
        if let Some(mut payment) = self.fetch_payment(&payment_hash) {
            payment.status = status;
            self.client
                .db()
                .insert_entry(&PaymentKey(*payment_hash), &payment)
                .expect("Db error");
        }
        // TODO: what to do if this payment doesn't exist?
    }
}

#[derive(Debug, Clone, Encodable, Decodable)]
struct ConfigKey;
const CONFIG_KEY_PREFIX: u8 = 0x50;

impl DatabaseKeyPrefixConst for ConfigKey {
    const DB_PREFIX: u8 = CONFIG_KEY_PREFIX;
    type Key = Self;

    type Value = String;
}

impl Client {
    pub async fn try_load(db: Box<dyn Database>) -> anyhow::Result<Option<Self>> {
        if let Some(cfg_json) = db.get_value(&ConfigKey).expect("db error") {
            Ok(Some(Self::new(db, &cfg_json).await?))
        } else {
            Ok(None)
        }
    }

    pub async fn new(db: Box<dyn Database>, cfg_json: &str) -> anyhow::Result<Self> {
        let connect_cfg: WsFederationConnect = serde_json::from_str(cfg_json)?;
        let api = WsFederationApi::new(connect_cfg.max_evil, connect_cfg.members);
        let cfg: ClientConfig = api.request("/config", ()).await?;

        // FIXME: this isn't the right thing to store
        db.insert_entry(&ConfigKey, &cfg_json.to_string())
            .expect("db error");

        Ok(Self {
            client: UserClient::new(UserClientConfig(cfg.clone()), db, Default::default()),
        })
    }

    pub async fn balance(&self) -> u64 {
        (self.client.coins().total_amount().milli_sat as f64 / 1000.) as u64
    }

    pub fn network(&self) -> bitcoin::Network {
        self.client.wallet_client().config.network
    }

    async fn pay_inner(&self, bolt11: Invoice) -> anyhow::Result<()> {
        let mut rng = rand::rngs::OsRng::new().unwrap();
        let http = reqwest::Client::new();

        let (contract_id, outpoint) = self
            .client
            .fund_outgoing_ln_contract(bolt11.clone(), &mut rng)
            .await?;

        self.client
            .await_outgoing_contract_acceptance(outpoint)
            .await?;

        let gw = self.client.fetch_active_gateway().await?;
        http.post(&format!("{}/pay_invoice", gw.api))
            .json(&contract_id)
            // .timeout(Duration::from_secs(15)) // TODO: add timeout
            .send()
            .await?;

        Ok(())
    }

    pub async fn pay(&self, invoice: String) -> anyhow::Result<()> {
        // Get rid of potential 'lightning:' prefix
        let bolt11 = invoice.split(':').last().expect("is always Some");

        let invoice: Invoice = bolt11.parse()?;
        match self.pay_inner(invoice.clone()).await {
            Ok(_) => {
                self.save_payment(&Payment::new(
                    invoice,
                    PaymentStatus::Paid,
                    PaymentDirection::Outgoing,
                ));
                self.client.fetch_all_coins().await;
                Ok(())
            }
            Err(e) => {
                self.save_payment(&Payment::new(
                    invoice,
                    PaymentStatus::Failed,
                    PaymentDirection::Outgoing,
                ));
                Err(e)
            }
        }
    }

    pub async fn invoice(&self, amount: u64, description: String) -> anyhow::Result<String> {
        let mut rng = rand::rngs::OsRng::new().unwrap();

        let amt = fedimint_api::Amount::from_sat(amount);
        let confirmed_invoice = self
            .client
            .generate_invoice(amt, description, &mut rng)
            .await
            .expect("Couldn't create invoice");
        let invoice = confirmed_invoice.invoice;

        // Save the keys and invoice for later polling`
        self.save_payment(&Payment::new(
            invoice.clone(),
            PaymentStatus::Pending,
            PaymentDirection::Incoming,
        ));
        tracing::info!("saved invoice to db");

        Ok(invoice.to_string())
    }

    // FIXME: there should be a cheaper way to check if we're connected
    pub async fn check_connection(&self) -> bool {
        match self.client.fetch_registered_gateways().await {
            Ok(_) => true,
            Err(_) => false,
        }
    }

    pub async fn poll(&self) {
        // Spawn a thread to check balances and claim incoming contracts
        loop {
            let mut requests = self
                .list_payments()
                .into_iter()
                // TODO: should we filter
                .filter(|payment| !payment.paid() && !payment.expired())
                .map(|payment| async move {
                    // FIXME: don't create rng in here ...
                    let invoice_expired = payment.invoice.is_expired();
                    let rng = rand::rngs::OsRng::new().unwrap();
                    let payment_hash = payment.invoice.payment_hash();
                    tracing::debug!("fetching incoming contract {:?}", &payment_hash);
                    let result = self
                        .client
                        .claim_incoming_contract(
                            ContractId::from_hash(payment_hash.clone()),
                            rng.clone(),
                        )
                        .await;
                    if let Err(_) = result {
                        tracing::debug!("couldn't complete payment: {:?}", &payment_hash);
                        // Mark it "expired" in db if we couldn't claim it and invoice is expired
                        if invoice_expired {
                            self.update_payment_status(payment_hash, PaymentStatus::Expired);
                        }
                    } else {
                        tracing::debug!("completed payment: {:?}", &payment_hash);
                        self.update_payment_status(payment_hash, PaymentStatus::Paid);
                        self.client.fetch_all_coins().await;
                    }
                })
                .collect::<FuturesUnordered<_>>();

            // FIXME: is there a better way to consume these futures?
            while let Some(_) = requests.next().await {
                tracing::info!("completed api request");
            }

            fedimint_api::task::sleep(std::time::Duration::from_secs(1)).await;
        }
    }
}

pub fn decode_invoice(invoice: String) -> anyhow::Result<BridgeInvoice> {
    // Get rid of potential 'lightning:' prefix
    let bolt11: Invoice = invoice
        .split(':')
        .last()
        .expect("is always Some")
        .parse()?;

    let amount = bolt11
        .amount_milli_satoshis()
        // FIXME:justin this is janky
        .map(|amount| (amount as f64 / 1000 as f64).round() as u64)
        .ok_or(anyhow!("Invoice missing amount"))?;

    let invoice = bolt11.to_string();

    // We might get no description
    let description = match bolt11.description() {
        InvoiceDescription::Direct(desc) => desc.to_string(),
        InvoiceDescription::Hash(_) => "".to_string(),
    };

    Ok(BridgeInvoice {
        amount,
        description,
        invoice,
        payment_hash: bolt11.payment_hash().to_string(),
    })
}
