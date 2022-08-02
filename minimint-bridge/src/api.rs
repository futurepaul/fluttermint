use std::path::{Path, PathBuf};
use std::sync::Arc;

use anyhow::{anyhow, Result};
use lazy_static::lazy_static;
use lightning_invoice::Invoice;
use mint_client::api::{WsFederationApi, WsFederationConnect};
use mint_client::UserClientConfig;
use serde::de::DeserializeOwned;
use tokio::runtime;
use tokio::sync::Mutex;

use crate::client::Client;

lazy_static! {
    static ref RUNTIME: runtime::Runtime = runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("failed to build runtime");
}

// FIXME: contents needs to be generic
fn _write_to_file(contents: String, path: PathBuf) -> Result<()> {
    let writer = std::fs::File::create(path)?;
    serde_json::to_writer_pretty(writer, &contents).unwrap();
    Ok(())
}

fn load_from_file<T: DeserializeOwned>(path: PathBuf) -> T {
    let file = std::fs::File::open(path).expect("Can't read cfg file.");
    serde_json::from_reader(file).expect("Could not parse cfg file.")
}

/// Map 127.0.0.1 to appropriate hostname for android / ios simulators
fn get_simulator_host() -> String {
    #[cfg(not(target_os = "android"))]
    let host = "localhost";
    #[cfg(target_os = "android")]
    let host = "10.0.2.2";
    return host.into();
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

    pub async fn set(client: Arc<Client>) {
        *GLOBAL_CLIENT.lock().await = Some(client);
    }
}

async fn set_client_from_config(path: String) -> Result<()> {
    let config_path = Path::new(&path).join("client.db");
    let cfg: UserClientConfig = load_from_file(config_path);
    let filename = Path::new(&path).join("client.db");
    let db = sled::open(&filename)?.open_tree("mint-client")?;
    let client = Arc::new(Client::new(Box::new(db), &cfg).await?);
    global_client::set(client.clone()).await;
    Ok(())
}

/// If this returns true, user has joined a federation. Otherwise they haven't.
pub fn init(path: String) -> Result<bool> {
    // Configure logging
    #[cfg(target_os = "android")]
    use tracing_subscriber::{layer::SubscriberExt, prelude::*, Layer};
    #[cfg(target_os = "android")]
    tracing_subscriber::registry()
        .with(
            paranoid_android::layer("com.example.flutter_rust_bridge_template")
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
                "com.example.flutter_rust_bridge_template",
                "INFO", // I don't know what this does ...
            )
            .with_filter(tracing_subscriber::filter::LevelFilter::INFO),
        )
        .try_init()
        .unwrap_or_else(|error| tracing::info!("Error installing logger: {}", error));

    tracing::info!("initialized");

    // Attempt to load a client from the filesystem config
    RUNTIME.block_on(async {
        match set_client_from_config(path).await {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })
}

// FIXME: rename config_url
pub fn join_federation(user_dir: String, config_url: String) -> Result<()> {
    RUNTIME.block_on(async {
        let ser: WsFederationConnect = serde_json::from_str(&config_url).unwrap(); // FIXME: unwrap
        let api = WsFederationApi::new(ser.max_evil, ser.members).await;
        let cfg: UserClientConfig = api.request("/config", ()).await?;
        let filename = Path::new(&user_dir).join("client.json");
        let writer = std::fs::File::create(&filename)?;
        serde_json::to_writer_pretty(writer, &cfg).expect("couldn't write config");

        let filename = Path::new(&user_dir).join("client.db");
        let db = sled::open(&filename)?.open_tree("mint-client")?;

        let client = Arc::new(Client::new(Box::new(db), &cfg).await?);
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

pub fn pay(bolt11: String) -> Result<String> {
    RUNTIME.block_on(async { global_client::get().await?.pay(bolt11).await })
}

pub struct MyInvoice {
    pub amount: u64,
    pub description: String,
    pub invoice: String,
}

pub fn decode_invoice(bolt11: String) -> Result<MyInvoice> {
    let bolt11: Invoice = bolt11.parse()?;

    let amount = bolt11
        .amount_milli_satoshis()
        .map(|amount| (amount as f64 / 1000 as f64).round() as u64)
        .ok_or(anyhow!("Invoice missing amount"))?;

    let description = bolt11
        .clone()
        .into_signed_raw()
        .description()
        .map(|d| d.clone().into_inner())
        .unwrap_or_default();

    let invoice = bolt11.to_string();

    return Ok(MyInvoice {
        amount,
        description,
        invoice,
    });
}

pub fn invoice(amount: u64, description: String) -> Result<String> {
    RUNTIME.block_on(async {
        global_client::get()
            .await?
            .invoice(amount, description)
            .await
    })
}
