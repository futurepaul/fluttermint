//! Minimint client with simpler types
use std::time::{Duration, SystemTime};

use anyhow::anyhow;
use bitcoin::hashes::sha256;
use fedimint_api::{
    config::ClientConfig,
    db::{Database, DatabaseKeyPrefixConst},
    encoding::{Decodable, Encodable, ModuleRegistry},
    NumPeers,
};
use fedimint_core::modules::ln::contracts::ContractId;
use fedimint_core::modules::ln::contracts::IdentifyableContract;
use futures::{stream::FuturesUnordered, StreamExt};
use lightning_invoice::Invoice;
use mint_client::{api::WsFederationApi, UserClient, UserClientConfig};
use mint_client::{api::WsFederationConnect, query::CurrentConsensus};

use crate::payments::{Payment, PaymentDirection, PaymentKey, PaymentKeyPrefix, PaymentStatus};

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
            .begin_transaction(ModuleRegistry::default())
            .get_value(&PaymentKey(payment_hash.clone()))
            .expect("Db error")
    }

    pub fn list_payments(&self) -> Vec<Payment> {
        self.client
            .db()
            .begin_transaction(ModuleRegistry::default())
            .find_by_prefix(&PaymentKeyPrefix)
            .map(|res| res.expect("Db error").1)
            .collect()
    }

    pub async fn save_payment(&self, payment: &Payment) {
        let mut dbtx = self
            .client
            .db()
            .begin_transaction(ModuleRegistry::default());
        dbtx.insert_entry(&PaymentKey(payment.invoice.payment_hash().clone()), payment)
            .expect("Db error");
        dbtx.commit_tx().await.expect("Db error");
    }

    pub async fn update_payment_status(&self, payment_hash: &sha256::Hash, status: PaymentStatus) {
        if let Some(mut payment) = self.fetch_payment(&payment_hash) {
            let mut dbtx = self
                .client
                .db()
                .begin_transaction(ModuleRegistry::default());
            payment.status = status;
            dbtx.insert_entry(&PaymentKey(*payment_hash), &payment)
                .expect("Db error");
            dbtx.commit_tx().await.expect("Db error");
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
    pub async fn try_load(db: Database) -> anyhow::Result<Option<Self>> {
        let db_clone = db.clone();
        let dbtx = db.begin_transaction(ModuleRegistry::default());
        if let Some(cfg_json) = dbtx.get_value(&ConfigKey).expect("db error") {
            Ok(Some(Self::new(db_clone, &cfg_json).await?))
        } else {
            Ok(None)
        }
    }

    pub async fn new(db: Database, cfg_json: &str) -> anyhow::Result<Self> {
        let connect_cfg: WsFederationConnect = serde_json::from_str(cfg_json)?;
        let api = WsFederationApi::new(connect_cfg.members);
        let cfg: ClientConfig = api
            // FIXME: is this the correct policy?
            .request(
                "/config",
                (),
                CurrentConsensus::new(api.peers().one_honest()),
            )
            .await?;

        // FIXME: this isn't the right thing to store
        let mut dbtx = db.begin_transaction(ModuleRegistry::default());
        dbtx.insert_entry(&ConfigKey, &cfg_json.to_string())
            .expect("db error");
        dbtx.commit_tx().await.expect("Db error");

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
        let mut rng = rand::rngs::OsRng;

        let (contract_id, outpoint) = self
            .client
            .fund_outgoing_ln_contract(bolt11.clone(), &mut rng)
            .await?;

        self.client
            .await_outgoing_contract_acceptance(outpoint)
            .await?;

        let result = self
            .client
            .await_outgoing_contract_execution(contract_id, &mut rng)
            .await;

        // FIXME: actually check that a refund happened
        if result.is_err() {
            self.client.fetch_all_coins().await;
        }

        Ok(result?)
    }

    // FIXME: this won't let you attempt to pay an invoice where previous payment failed
    // Trying to avoid losing funds at the expense of UX ...
    pub fn can_pay(&self, invoice: &Invoice) -> bool {
        // If there isn't an outgoing fluttermint payment, we can pay
        self.list_payments()
            .iter()
            .filter(|payment| payment.outgoing() && &payment.invoice == invoice)
            .next()
            .is_none()
    }

    pub async fn pay(&self, bolt11: String) -> anyhow::Result<()> {
        let invoice: Invoice = bolt11.parse()?;

        if !self.can_pay(&invoice) {
            return Err(anyhow!("Can't pay invoice twice"));
        }

        match self.pay_inner(invoice.clone()).await {
            Ok(_) => {
                self.save_payment(&Payment::new(
                    invoice,
                    PaymentStatus::Paid,
                    PaymentDirection::Outgoing,
                ))
                .await;
                self.client.fetch_all_coins().await;
                Ok(())
            }
            Err(e) => {
                self.save_payment(&Payment::new(
                    invoice,
                    PaymentStatus::Failed,
                    PaymentDirection::Outgoing,
                ))
                .await;
                Err(e)
            }
        }
    }

    pub async fn invoice(&self, amount: u64, description: String) -> anyhow::Result<String> {
        let mut rng = rand::rngs::OsRng;

        let amt = fedimint_api::Amount::from_sat(amount);
        let confirmed_invoice = self
            .client
            .generate_invoice(amt, description, &mut rng, None)
            .await
            .expect("Couldn't create invoice");
        let invoice = confirmed_invoice.invoice;

        // Save the keys and invoice for later polling`
        self.save_payment(&Payment::new(
            invoice.clone(),
            PaymentStatus::Pending,
            PaymentDirection::Incoming,
        ))
        .await;
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

    async fn block_height(&self) -> anyhow::Result<u64> {
        Ok(self
            .client
            .wallet_client()
            .context
            .api
            .fetch_consensus_block_height()
            .await?)
    }

    pub async fn poll(&self) {
        let mut last_outgoing_check = SystemTime::now();
        loop {
            // Try to complete incoming payments
            let mut requests = self
                .list_payments()
                .into_iter()
                // TODO: should we filter
                .filter(|payment| !payment.paid() && !payment.expired() && payment.incoming())
                .map(|payment| async move {
                    // FIXME: don't create rng in here ...
                    let invoice_expired = payment.invoice.is_expired();
                    let rng = rand::rngs::OsRng;
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
                            self.update_payment_status(payment_hash, PaymentStatus::Expired)
                                .await;
                        }
                    } else {
                        tracing::debug!("completed payment: {:?}", &payment_hash);
                        self.update_payment_status(payment_hash, PaymentStatus::Paid)
                            .await;
                        self.client.fetch_all_coins().await;
                    }
                })
                .collect::<FuturesUnordered<_>>();

            // FIXME: is there a better way to consume these futures?
            while let Some(_) = requests.next().await {
                tracing::info!("completed api request");
            }

            // Only check outgoing payments once per minute
            if last_outgoing_check
                .elapsed()
                .expect("Unix time not available")
                > Duration::from_secs(60)
            {
                // Try to complete outgoing payments
                let consensus_block_height = match self.block_height().await {
                    Ok(height) => height,
                    Err(_) => {
                        tracing::error!("failed to get block height");
                        continue;
                    }
                };

                // TODO: only do this once per minute
                tracing::info!("looking for refunds...");
                let mut requests = self
                    .client
                    .ln_client()
                    .refundable_outgoing_contracts(consensus_block_height)
                    .into_iter()
                    .map(|contract| async move {
                        tracing::info!(
                            "attempting to get refund {:?}",
                            contract.contract_account.contract.contract_id(),
                        );
                        match self
                            .client
                            .try_refund_outgoing_contract(
                                contract.contract_account.contract.contract_id(),
                                rand::rngs::OsRng,
                            )
                            .await
                        {
                            Ok(_) => {
                                tracing::info!("got refund");
                                self.client.fetch_all_coins().await;
                            }
                            Err(e) => tracing::info!("refund failed {:?}", e),
                        }
                    })
                    .collect::<FuturesUnordered<_>>();

                // FIXME: is there a better way to consume these futures?
                while let Some(_) = requests.next().await {
                    tracing::info!("completed api request");
                }
                last_outgoing_check = SystemTime::now();
            }

            fedimint_api::task::sleep(std::time::Duration::from_secs(1)).await;
        }
    }
}
