//! Minimint client with simpler types

use anyhow::anyhow;
use fedimint_api::{
    db::{Database, DatabaseKeyPrefixConst},
    encoding::{Decodable, Encodable},
};
use fedimint_core::config::ClientConfig;
use fedimint_core::modules::ln::contracts::ContractId;
use futures::stream::FuturesUnordered;
use futures::StreamExt;
use lightning_invoice::Invoice;
use mint_client::api::WsFederationConnect;
use mint_client::{api::WsFederationApi, UserClient, UserClientConfig};
use serde_json::json;

pub struct Client {
    pub(crate) client: UserClient,
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
            // payments: Mutex::new(Vec::new()),
        })
    }

    pub async fn balance(&self) -> u64 {
        (self.client.coins().amount().milli_sat as f64 / 1000.) as u64
    }

    pub async fn pay(&self, bolt11: String) -> anyhow::Result<()> {
        let mut rng = rand::rngs::OsRng::new().unwrap();
        let http = reqwest::Client::new();
        let bolt11: Invoice = bolt11.parse()?;

        let (contract_id, outpoint) = self
            .client
            .fund_outgoing_ln_contract(bolt11, &mut rng)
            .await
            .expect("Not enough coins");

        self.client
            .await_outgoing_contract_acceptance(outpoint)
            .await
            .expect("Contract wasn't accepted in time");

        let gw = self.client.fetch_active_gateway().await?;
        http.post(&format!("{}/pay_invoice", gw.api))
            .json(&contract_id)
            // .timeout(Duration::from_secs(15)) // TODO: add timeout
            .send()
            .await
            .unwrap();

        self.client.fetch_all_coins().await;

        Ok(())
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
        self.client.ln_client().save_pending_invoice(&invoice);
        tracing::info!("saved invoice to db");

        Ok(invoice.to_string())
    }

    pub async fn poll(&self) {
        // Spawn a thread to check balances and claim incoming contracts
        loop {
            let mut requests = self
                .client
                .ln_client()
                .list_pending_invoices()
                .into_iter()
                .filter(|invoice| !invoice.is_expired())
                .map(|invoice| async move {
                    // FIXME: don't create rng in here ...
                    let rng = rand::rngs::OsRng::new().unwrap();
                    tracing::info!("fetching incoming contract {:?}", invoice.payment_hash());
                    let result = self
                        .client
                        .claim_incoming_contract(
                            ContractId::from_hash(invoice.payment_hash().clone()),
                            rng.clone(),
                        )
                        .await;
                    if let Err(_) = result {
                        tracing::info!("couldn't complete payment: {:?}", invoice.payment_hash());
                    } else {
                        tracing::info!("completed payment: {:?}", invoice.payment_hash());
                        // TODO: mark it paid in database
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
    });
    Ok(serde_json::to_string(&json)?)
}
