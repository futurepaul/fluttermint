//! Minimint client with simpler types

use std::{io::Cursor, str::FromStr, time::Duration};

use anyhow::anyhow;
use bitcoin::{Address, Amount, KeyPair, Txid};
use bitcoincore_rpc::{Auth, RpcApi};
use lightning_invoice::Invoice;
use minimint::modules::{ln::contracts::ContractId, wallet::txoproof::TxOutProof};
use minimint_api::{db::Database, encoding::Decodable, OutPoint};
use mint_client::{
    ln::gateway::LightningGateway, ClientAndGatewayConfig,
    UserClient,
};
use tokio::sync::Mutex;

pub struct Client {
    client: UserClient,
    gateway_cfg: LightningGateway,
    payments: Mutex<Vec<(KeyPair, Invoice)>>,
}

impl Client {
    pub async fn new(db: Box<dyn Database>, cfg_json: &str) -> anyhow::Result<Self> {
        let cfg: ClientAndGatewayConfig = serde_json::from_str(cfg_json)?;
        tracing::info!("parsed config {:?}\n\n\n", cfg);
        Ok(Self {
            client: UserClient::new(cfg.client, db, Default::default()).await,
            gateway_cfg: cfg.gateway,
            payments: Mutex::new(Vec::new()),
        })
    }

    pub fn address(&self) -> String {
        let mut rng = rand::rngs::OsRng::new().unwrap();
        self.client.get_new_pegin_address(&mut rng).to_string()
    }

    pub async fn balance(&self) -> u64 {
        self.client.coins().amount().milli_sat
    }

    pub async fn pegin(&self, txid: &str, host: &str) -> anyhow::Result<String> {
        let txid: Txid = txid.parse()?;
        let mut rng = rand::rngs::OsRng::new().unwrap();
        let url = format!("http://{}:18443/wallet/default", host);
        let auth = Auth::UserPass("bitcoin".into(), "bitcoin".into());
        let rpc_client = bitcoincore_rpc::Client::new(&url, auth)?;

        let tx = rpc_client.get_raw_transaction(&txid, None)?;
        let _txout_proof = rpc_client.get_tx_out_proof(&[txid], None)?;
        let txout_proof = TxOutProof::consensus_decode(Cursor::new(_txout_proof))
            .map_err(|e| anyhow!("{:?}", e))?;

        let id = self.client.peg_in(txout_proof, tx, &mut rng).await?;

        let outpoint = OutPoint {
            txid: id,
            out_idx: 0,
        };

        loop {
            let result = self.client.fetch_coins(outpoint).await;

            match result {
                Ok(()) => return Ok("ok".to_string()), // FIXME
                Err(err) if err.is_retryable() => {
                    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
                    continue;
                }
                Err(err) => Err(err)?,
            };
        }
    }

    pub async fn pegout(&self, address: &str) -> anyhow::Result<String> {
        let mut rng = rand::rngs::OsRng::new().unwrap();
        let txid = self
            .client
            .peg_out(
                Amount::from_sat(1_000),
                Address::from_str(&address)?,
                &mut rng,
            )
            .await?;
        Ok(format!("{:?}", txid))
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
        let (keypair, unconfirmed_invoice) = self
            .client
            .create_unconfirmed_invoice(amt, "TODO: description".to_string(), &mut rng)
            .await
            .expect("Couldn't create invoice");

        let invoice = self.client.confirm_invoice(unconfirmed_invoice).await.expect("Couldn't confirm invoice");

        self.payments
            .lock()
            .await
            .push((keypair, invoice.clone()));

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
            for (keypair, invoice) in payments_guard.iter() {
                tracing::info!(
                    "fetching incoming contract {:?} {:?}",
                    invoice.payment_hash(),
                    keypair.clone()
                );
                let result = self
                    .client
                    .claim_incoming_contract(
                        ContractId::from_hash(invoice.payment_hash().clone()),
                        keypair.clone(),
                        rng.clone(),
                    )
                    .await;
                if let Err(_) = result {
                    // TODO: filter out expired invoices
                    tracing::info!(
                        "couldn't complete payment: {:?}",
                        invoice.payment_hash()
                    );
                    new_payments.push((keypair.clone(), invoice.clone()));
                } else {
                    tracing::info!(
                        "completed payment: {:?}",
                        invoice.payment_hash()
                    );
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
