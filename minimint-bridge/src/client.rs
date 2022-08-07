//! Minimint client with simpler types

use std::time::Duration;

use lightning_invoice::Invoice;
use minimint_api::{
    db::{Database, DatabaseKeyPrefixConst},
    encoding::{Decodable, Encodable},
};
use minimint_core::modules::ln::contracts::ContractId;
use mint_client::{ln::gateway::LightningGateway, UserClient, UserClientConfig};
use tokio::sync::Mutex;

pub struct Client {
    client: UserClient,
    gateway_cfg: LightningGateway,
    payments: Mutex<Vec<Invoice>>,
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
        let cfg: UserClientConfig = serde_json::from_str(cfg_json)?;
        tracing::info!("parsed config {:?}\n\n\n", cfg);

        db.insert_entry(&ConfigKey, &cfg_json.to_string())
            .expect("db error");

        Ok(Self {
            client: UserClient::new(cfg.clone(), db, Default::default()).await,
            gateway_cfg: cfg.gateway,
            payments: Mutex::new(Vec::new()),
        })
    }

    pub async fn balance(&self) -> u64 {
        self.client.coins().amount().milli_sat
    }

    pub async fn pay(&self, bolt11: String) -> anyhow::Result<String> {
        let mut rng = rand::rngs::OsRng::new().unwrap();
        let http = reqwest::Client::new();
        let bolt11: Invoice = bolt11.parse()?;

        let (contract_id, outpoint) = self
            .client
            .fund_outgoing_ln_contract(&self.gateway_cfg, bolt11, &mut rng)
            .await
            .expect("Not enough coins");

        self.client
            .await_outgoing_contract_acceptance(outpoint)
            .await
            .expect("Contract wasn't accepted in time");

        let r = http
            .post(&format!("{}/pay_invoice", self.gateway_cfg.api))
            .json(&contract_id)
            .timeout(Duration::from_secs(15))
            .send()
            .await
            .unwrap();

        Ok(format!("{:?}", r))
    }

    pub async fn invoice(&self, amount: u64) -> anyhow::Result<String> {
        let mut rng = rand::rngs::OsRng::new().unwrap();

        // Save the keys and invoice for later polling`
        let amt = minimint_api::Amount::from_sat(amount);
        let confirmed_invoice = self
            .client
            .generate_invoice(
                amt,
                "TODO: description".to_string(),
                &self.gateway_cfg,
                &mut rng,
            )
            .await
            .expect("Couldn't create invoice");

        let invoice = confirmed_invoice.invoice;

        self.payments.lock().await.push(invoice.clone());

        Ok(invoice.to_string())
    }

    pub async fn poll(&self) {
        let rng = rand::rngs::OsRng::new().unwrap();
        // Spawn a thread to check balances and claim incoming contracts
        loop {
            tracing::info!("polling...");

            // Complete incoming payments
            let mut payments_guard = self.payments.lock().await;
            let mut new_payments = vec![];
            for invoice in payments_guard.iter() {
                tracing::info!("fetching incoming contract {:?}", invoice.payment_hash(),);
                let result = self
                    .client
                    .claim_incoming_contract(
                        ContractId::from_hash(invoice.payment_hash().clone()),
                        rng.clone(),
                    )
                    .await;
                if let Err(_) = result {
                    // TODO: filter out expired invoices
                    tracing::info!("couldn't complete payment: {:?}", invoice.payment_hash());
                    new_payments.push(invoice.clone());
                } else {
                    tracing::info!("completed payment: {:?}", invoice.payment_hash());
                }
            }

            // Fetch balance
            // let initial_balance = client.coins().amount();
            // client.fetch_all_coins().await.unwrap();
            // let balance = client.coins().amount();
            // tracing::info!(
            //     "fetched coins {} -> {}",
            //     initial_balance.milli_sat,
            //     balance.milli_sat
            // );

            // Reset hacky payment info
            *payments_guard = new_payments;

            tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        }
    }
}
