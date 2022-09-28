use std::path::Path;
use std::sync::Arc;

use anyhow::{anyhow, Result};
use bitcoin::hashes::sha256;
use bitcoin::Network;
use fedimint_sled::SledDb;
use lazy_static::lazy_static;
use lightning_invoice::{Invoice, InvoiceDescription};
use mint_client::utils::network_to_currency;
use tokio::runtime;
use tokio::sync::Mutex;

use crate::client::{Client, ConnectionStatus};
use crate::payments::{PaymentDirection, PaymentStatus};

lazy_static! {
    static ref RUNTIME: runtime::Runtime = runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("failed to build runtime");
}
mod global_client {
    use tokio::task::JoinHandle;

    use super::*;

    static GLOBAL_CLIENT: Mutex<Option<Arc<Client>>> = Mutex::const_new(None);
    static GLOBAL_POLLER: Mutex<Option<JoinHandle<()>>> = Mutex::const_new(None);
    static GLOBAL_USER_DIR: Mutex<Option<String>> = Mutex::const_new(None);

    // Justin: static function to return a reference to the federation you're working on.
    // Dart side can call methods on it.

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
        // Remove client
        *GLOBAL_CLIENT.lock().await = None;

        // Kill poller
        let poller = GLOBAL_POLLER.lock().await;
        tracing::info!("poller {:?}", poller);
        if let Some(handle) = poller.as_ref() {
            handle.abort();
        }

        tracing::info!("Client removed");
        Ok(())
    }

    pub async fn delete_database() -> Result<()> {
        // Wipe database
        if let Some(user_dir) = GLOBAL_USER_DIR.lock().await.as_ref() {
            let db_dir = Path::new(&user_dir).join("client.db");
            std::fs::remove_dir_all(db_dir)?;
        }
        Ok(())
    }

    pub async fn set(client: Arc<Client>) {
        *GLOBAL_CLIENT.lock().await = Some(client.clone());
        let poller = tokio::spawn(async move { client.poll().await });
        *GLOBAL_POLLER.lock().await = Some(poller);
    }

    pub async fn get_user_dir() -> Result<String> {
        let user_dir = GLOBAL_USER_DIR
            .lock()
            .await
            .as_ref()
            .ok_or(anyhow!("not initialized"))?
            .clone();
        Ok(user_dir)
    }

    pub async fn set_user_dir(user_dir: String) {
        *GLOBAL_USER_DIR.lock().await = Some(user_dir.clone());
        tracing::info!("set user dir {}", &user_dir);
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
        global_client::set_user_dir(path.clone()).await;
        if global_client::is_some().await {
            return connection_status_private().await;
        };
        let filename = Path::new(&path).join("client.db");
        // TODO: use federation name as "tree"
        let db = SledDb::open(filename, "client")?;
        if let Some(client) = Client::try_load(db.into()).await? {
            let client = Arc::new(client);
            global_client::set(client.clone()).await;
            let status = connection_status_private().await?;
            return Ok(status);
        }
        Ok(ConnectionStatus::NotConfigured)
    })
}

pub fn join_federation(config_url: String) -> Result<()> {
    RUNTIME.block_on(async {
        let user_dir = global_client::get_user_dir().await?;
        tracing::info!("user dir {}", user_dir);
        let filename = Path::new(&user_dir).join("client.db");
        // TODO: use federation name as "tree"
        let db = SledDb::open(filename, "client")?;
        let client = Arc::new(Client::new(db.into(), &config_url).await?);
        // for good measure, make sure the balance is updated (FIXME)
        client.client.fetch_all_coins().await;
        global_client::set(client.clone()).await;
        Ok(())
    })
}

/// Unset client and wipe database. Ecash will be destroyed. Use with caution!!!
pub fn leave_federation() -> Result<()> {
    RUNTIME.block_on(async {
        global_client::remove().await?;
        global_client::delete_database().await?;
        Ok(())
    })
}

pub fn balance() -> Result<u64> {
    RUNTIME.block_on(async { Ok(global_client::get().await?.balance().await) })
}

pub fn pay(bolt11: String) -> Result<()> {
    RUNTIME.block_on(async { global_client::get().await?.pay(bolt11).await })
}

pub fn invoice(amount: u64, description: String) -> Result<String> {
    RUNTIME.block_on(async {
        let client = global_client::get().await?;

        if client.network() == Network::Bitcoin && amount > 60000 {
            return Err(anyhow!("Maximum invoice size on mainnet is 60000 sats"));
        }

        client.invoice(amount, description).await
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
    pub direction: PaymentDirection,
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
            invoice: decode_invoice_inner(&payment.invoice)?,
            status: payment.status,
            created_at: payment.created_at,
            paid: payment.paid(),
            direction: payment.direction,
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
            // TODO From impl
            .map(|payment| BridgePayment {
                // FIXME: don't expect
                invoice: decode_invoice_inner(&payment.invoice).expect("couldn't decode invoice"),
                status: payment.status,
                created_at: payment.created_at,
                paid: payment.paid(),
                direction: payment.direction,
            })
            .collect();
        Ok(payments)
    })
}

// TODO why does this even have to be a result>
async fn configured_status_private() -> Result<bool> {
    if global_client::is_some().await {
        return Ok(true);
    } else {
        return Ok(false);
    }
}

pub fn configured_status() -> Result<bool> {
    RUNTIME.block_on(async { configured_status_private().await })
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

pub fn calculate_fee(bolt11: String) -> Result<Option<u64>> {
    let invoice: Invoice = bolt11.parse()?;
    let fee = invoice
        .amount_milli_satoshis()
        .map(|msat| {
            // Add 1% fee margin
            msat / 100
        })
        // FIXME janky msat -> sat conversion
        .map(|msat| (msat as f64 / 1000 as f64).round() as u64);
    Ok(fee)
}

/// Bridge representation of a fedimint node
#[derive(Clone, Debug)]
pub struct BridgeGuardianInfo {
    pub name: String,
    pub address: String,
    pub online: bool,
}

/// Bridge representation of a fedimint node
#[derive(Clone, Debug)]
pub struct BridgeFederationInfo {
    pub name: String,
    pub network: String,
    pub current: bool,
    pub guardians: Vec<BridgeGuardianInfo>,
}

/// Returns the federations we're members of
///
/// At most one will be `active`
pub fn list_federations() -> Vec<BridgeFederationInfo> {
    return vec![
        BridgeFederationInfo {
            name: "Trimont State Bank".into(),
            network: Network::Bitcoin.to_string(),
            current: true,
            guardians: vec![
                BridgeGuardianInfo {
                    name: "Tony".into(),
                    address: "https://locahost:5000".into(),
                    online: true,
                },
                BridgeGuardianInfo {
                    name: "Cal".into(),
                    address: "https://locahost:6000".into(),
                    online: false,
                },
            ],
        },
        BridgeFederationInfo {
            name: "CypherU".into(),
            network: Network::Signet.to_string(),
            current: false,
            guardians: vec![
                BridgeGuardianInfo {
                    name: "Eric".into(),
                    address: "https://locahost:7000".into(),
                    online: false,
                },
                BridgeGuardianInfo {
                    name: "Obi".into(),
                    address: "https://locahost:8000".into(),
                    online: true,
                },
            ],
        },
    ];
}

/// Switch to a federation that we've already joined
///
/// This assumes federation config is already saved locally
pub fn switch_federation(_federation: BridgeFederationInfo) -> Result<()> {
    Ok(())
}

/// Decodes an invoice and checks that we can pay it
pub fn decode_invoice(bolt11: String) -> Result<BridgeInvoice> {
    RUNTIME.block_on(async {
        let client = global_client::get().await?;
        let invoice: Invoice = match bolt11.parse() {
            Ok(i) => Ok(i),
            Err(_) => Err(anyhow!("Invalid lightning invoice")),
        }?;
        if !client.can_pay(&invoice) {
            return Err(anyhow!("Can't pay invoice twice"));
        }
        if network_to_currency(client.network()) != invoice.currency() {
            return Err(anyhow!(format!(
                "Wrong network. Expected {}, got {}",
                network_to_currency(client.network()),
                invoice.currency()
            )));
        }
        if invoice.is_expired() {
            return Err(anyhow!("Invoice is expired"));
        }
        decode_invoice_inner(&invoice)
    })
}

fn decode_invoice_inner(invoice: &Invoice) -> anyhow::Result<BridgeInvoice> {
    let amount = invoice
        .amount_milli_satoshis()
        // FIXME:justin this is janky
        .map(|amount| (amount as f64 / 1000 as f64).round() as u64)
        .ok_or(anyhow!("Invoice missing amount"))?;

    // We might get no description
    let description = match invoice.description() {
        InvoiceDescription::Direct(desc) => desc.to_string(),
        InvoiceDescription::Hash(_) => "".to_string(),
    };

    Ok(BridgeInvoice {
        amount,
        description,
        invoice: invoice.to_string(),
        payment_hash: invoice.payment_hash().to_string(),
    })
}
