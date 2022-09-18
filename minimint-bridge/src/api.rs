use std::path::Path;
use std::sync::Arc;

use anyhow::{anyhow, Result};
use bitcoin::hashes::sha256;
use lazy_static::lazy_static;
use tokio::runtime;
use tokio::sync::Mutex;

use crate::client::{Client, ConnectionStatus};
use crate::payments::PaymentStatus;

lazy_static! {
    static ref RUNTIME: runtime::Runtime = runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("failed to build runtime");
}

mod global_client {
    use super::*;

    static GLOBAL_CLIENT: Mutex<Option<Arc<Client>>> = Mutex::const_new(None);

    pub async fn get() -> Result<Arc<Client>> {
        let client = GLOBAL_CLIENT
            .lock()
            .await
            .as_ref()
            .ok_or(anyhow!("join a federation first"))?
            .clone();
        Ok(client)
    }

    pub async fn is_some() -> bool {
        GLOBAL_CLIENT.lock().await.is_some()
    }

    pub async fn remove() -> Result<()> {
        *GLOBAL_CLIENT.lock().await = None;
        tracing::info!("Client removed");
        Ok(())
    }

    pub async fn set(client: Arc<Client>) {
        *GLOBAL_CLIENT.lock().await = Some(client);
    }
}

pub fn init(path: String) -> Result<ConnectionStatus> {
    tracing::info!("called init()");
    // Configure logging
    #[cfg(target_os = "android")]
    use tracing_subscriber::{layer::SubscriberExt, prelude::*, Layer};
    #[cfg(target_os = "android")]
    tracing_subscriber::registry()
        .with(
            paranoid_android::layer("com.justinmoon.fluttermint")
                .with_filter(tracing_subscriber::filter::LevelFilter::INFO),
        )
        .try_init()
        .unwrap_or_else(|error| tracing::info!("Error installing logger: {}", error));

    #[cfg(target_os = "ios")]
    use tracing_subscriber::{layer::SubscriberExt, prelude::*, Layer};
    #[cfg(target_os = "ios")]
    tracing_subscriber::registry()
        .with(
            tracing_oslog::OsLogger::new(
                "com.justinmoon.fluttermint",
                "INFO", // I don't know what this does ...
            )
            .with_filter(tracing_subscriber::filter::LevelFilter::INFO),
        )
        .try_init()
        .unwrap_or_else(|error| tracing::info!("Error installing logger: {}", error));

    #[cfg(target_os = "macos")]
    tracing_subscriber::fmt()
        .try_init()
        .unwrap_or_else(|error| tracing::info!("Error installing logger: {}", error));

    RUNTIME.block_on(async {
        if global_client::is_some().await {
            return connection_status_private().await;
        };
        global_client::remove().await?;
        let filename = Path::new(&path).join("client.db");
        let db = sled::open(&filename)?.open_tree("mint-client")?;
        if let Some(client) = Client::try_load(Box::new(db)).await? {
            let client = Arc::new(client);
            global_client::set(client.clone()).await;
            // TODO: kill the poll task on leave
            tokio::spawn(async move { client.poll().await });
            let status = connection_status_private().await?;
            return Ok(status);
        }
        Ok(ConnectionStatus::NotConfigured)
    })
}

pub fn join_federation(user_dir: String, config_url: String) -> Result<()> {
    RUNTIME.block_on(async {
        global_client::remove().await?;
        let filename = Path::new(&user_dir).join("client.db");
        std::fs::remove_dir_all(&filename)?;
        let db = sled::open(&filename)?.open_tree("mint-client")?;
        let client = Arc::new(Client::new(Box::new(db), &config_url).await?);
        global_client::set(client.clone()).await;
        // TODO: kill the poll task on leave
        tokio::spawn(async move { client.poll().await });
        Ok(())
    })
}

pub fn leave_federation() -> Result<()> {
    // delete the database (their ecash tokens will disappear ... this shouldn't be done lightly ...)
    // set CLIENT to None
    Ok(())
}

pub fn balance() -> Result<u64> {
    RUNTIME.block_on(async { Ok(global_client::get().await?.balance().await) })
}

pub fn pay(bolt11: String) -> Result<()> {
    RUNTIME.block_on(async { global_client::get().await?.pay(bolt11).await })
}

pub fn decode_invoice(bolt11: String) -> Result<BridgeInvoice> {
    crate::client::decode_invoice(bolt11)
}

pub fn invoice(amount: u64, description: String) -> Result<String> {
    RUNTIME.block_on(async {
        global_client::get()
            .await?
            .invoice(amount, description)
            .await
    })
}

// TODO: impl From<Payment>
// Do the "expired" conversion in there, too
#[derive(Clone, Debug)]
pub struct BridgePayment {
    pub invoice: BridgeInvoice,
    pub status: PaymentStatus,
    pub created_at: u64,
    pub paid: bool,
}

#[derive(Clone, Debug)]
pub struct BridgeInvoice {
    pub payment_hash: String,
    pub amount: u64,
    pub description: String,
    pub invoice: String,
}

pub fn fetch_payment(payment_hash: String) -> Result<BridgePayment> {
    let hash: sha256::Hash = payment_hash.parse()?;
    RUNTIME.block_on(async {
        let payment = global_client::get()
            .await?
            .fetch_payment(&hash)
            .ok_or(anyhow!("payment not found"))?;
        Ok(BridgePayment {
            invoice: decode_invoice(payment.invoice.to_string())?,
            status: payment.status,
            created_at: payment.created_at,
            paid: payment.paid(),
        })
    })
}

pub fn list_payments() -> Result<Vec<BridgePayment>> {
    println!("Listing payments...");
    RUNTIME.block_on(async {
        let payments = global_client::get()
            .await?
            .list_payments()
            .iter()
            .map(|payment| BridgePayment {
                // FIXME: don't expect
                invoice: decode_invoice(payment.invoice.to_string())
                    .expect("couldn't decode invoice"),
                status: payment.status,
                created_at: payment.created_at,
                paid: payment.paid(),
            })
            .collect();
        Ok(payments)
    })
}

async fn connection_status_private() -> Result<ConnectionStatus> {
    if !global_client::is_some().await {
        return Ok(ConnectionStatus::NotConfigured);
    }
    match global_client::get().await?.check_connection().await {
        true => Ok(ConnectionStatus::Connected),
        false => Ok(ConnectionStatus::NotConnected),
    }
}

pub fn connection_status() -> Result<ConnectionStatus> {
    RUNTIME.block_on(async { connection_status_private().await })
}

pub fn network() -> Result<String> {
    RUNTIME.block_on(async { Ok(global_client::get().await?.network().to_string()) })
}
