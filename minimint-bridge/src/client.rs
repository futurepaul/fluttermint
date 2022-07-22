//! Minimint client with simpler types
use lightning_invoice::Invoice;
use minimint::modules::ln::contracts::ContractId;
use minimint_api::db::Database;
use mint_client::{UserClient, UserClientConfig};
use tokio::sync::Mutex;

pub struct Client {
    client: UserClient,
    payments: Mutex<Vec<Invoice>>,
}

impl Client {
    pub async fn new(db: Box<dyn Database>, cfg: &UserClientConfig) -> anyhow::Result<Self> {
        Ok(Self {
            client: UserClient::new(cfg.clone(), db, Default::default()).await,
            payments: Mutex::new(Vec::new()),
        })
    }

    pub async fn balance(&self) -> u64 {
        self.client.coins().amount().milli_sat
    }

    pub async fn pay(&self, bolt11: String) -> anyhow::Result<String> {
        let mut rng = rand::rngs::OsRng::new().unwrap();
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

        let r = self
            .client
            .await_outgoing_contract_execution(contract_id)
            .await?;

        Ok(format!("{:?}", r))
    }

    pub async fn invoice(&self, amount: u64) -> anyhow::Result<String> {
        let mut rng = rand::rngs::OsRng::new().unwrap();

        // Save the keys and invoice for later polling`
        let amt = minimint_api::Amount::from_sat(amount);
        let confirmed_invoice = self
            .client
            .generate_invoice(amt, "TODO: description".to_string(), &mut rng)
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
            let mut completed_payments = vec![];
            for (index, invoice) in payments_guard.iter().enumerate() {
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
                    if invoice.is_expired() {
                        completed_payments.push(index);
                    }
                } else {
                    tracing::info!("completed payment: {:?}", invoice.payment_hash());
                    completed_payments.push(index);
                }
            }

            // Remove completed or expired invoices
            for index in completed_payments.into_iter() {
                new_payments.remove(index);
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
