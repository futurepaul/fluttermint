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
use lightning_invoice::Invoice;
use mint_client::api::WsFederationConnect;
use mint_client::{api::WsFederationApi, UserClient, UserClientConfig};
use serde_json::json;

use crate::payments::{Payment, PaymentKey, PaymentKeyPrefix};

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

    pub async fn pay(&self, bolt11: String) -> anyhow::Result<()> {
        let invoice: Invoice = bolt11.parse()?;
        match self.pay_inner(invoice.clone()).await {
            Ok(_) => {
                self.save_payment(&Payment::new_paid(invoice));
                self.client.fetch_all_coins().await;
                Ok(())
            }
            Err(e) => {
                self.save_payment(&Payment::new_failed(invoice));
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
        self.save_payment(&Payment::new_pending(invoice.clone()));
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
                            self.save_payment(&Payment::new_expired(payment.invoice.clone()));
                        }
                    } else {
                        tracing::debug!("completed payment: {:?}", &payment_hash);
                        self.save_payment(&Payment::new_paid(payment.invoice.clone()));
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

pub fn decode_invoice(bolt11: String) -> anyhow::Result<String> {
    let bolt11: Invoice = bolt11.parse()?;

    let amount = bolt11
        .amount_milli_satoshis()
        // FIXME:justin this is janky
        .map(|amount| (amount as f64 / 1000 as f64).round() as u64)
        .ok_or(anyhow!("Invoice missing amount"))?;

    let invoice = bolt11.to_string();
    let json = json!({
        "amount": amount,
        "description": "Testing".to_string(),
        // FIXME: I assume this doesn't work in WASM
        // "description": bolt11.description().to_owned().to_string(),
        "invoice": invoice,
        "paymentHash": bolt11.payment_hash()
    });

    Ok(serde_json::to_string(&json)?)
}
