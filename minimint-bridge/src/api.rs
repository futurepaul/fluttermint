use std::path::Path;
use std::path::PathBuf;
use std::sync::Arc;

use anyhow::{anyhow, Result};
use lazy_static::lazy_static;
use lightning_invoice::Invoice;
use minimint_api::db::mem_impl::MemDatabase;
use minimint_api::PeerId;
use mint_client::api::{WsFederationApi, WsFederationApiSer};
use mint_client::UserClientConfig;
use tokio::runtime;
use tokio::sync::Mutex;

use crate::client::Client;

lazy_static! {
    static ref RUNTIME: runtime::Runtime = runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("failed to build runtime");
}

fn _write_to_file(contents: String, path: PathBuf) -> Result<()> {
    let writer = std::fs::File::create(path)?;
    serde_json::to_writer_pretty(writer, &contents).unwrap();
    Ok(())
}

fn get_host() -> String {
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

/// If this returns Some, user has joined a federation. Otherwise they haven't.
pub fn init() -> Result<bool> {
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
    Ok(true)
}

// FIXME: rename config_url
pub fn join_federation(user_dir: String, config_url: String) -> Result<()> {
    RUNTIME.block_on(async {
        tracing::info!("config: {:?}", config_url);
        // For Real
        // let config_url = config_url.replace("127.0.0.1", &get_host());
        let ser: WsFederationApiSer = serde_json::from_str(&config_url).unwrap(); // FIXME: unwrap
        let api = WsFederationApi::new(ser.max_evil, ser.members).await;
        let cfg: UserClientConfig = api.request("/config", ()).await?;
        println!("config {:?}", cfg);

        // TODO: getting "read only filesystem" error ...
        // let filename = Path::new(&user_dir).join("client.db");
        // let db = sled::open(&filename)?.open_tree("mint-client")?;
        let db = MemDatabase::new();
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
    pub amount: Option<u64>,
    pub description: String,
    pub invoice: String,
}

pub fn decode_invoice(bolt11: String) -> Result<MyInvoice> {
    tracing::info!("rust decoding: {}", bolt11);
    let bolt11: Invoice = bolt11.parse()?;

    let amount = bolt11.amount_milli_satoshis();
    // let description = bolt11.to_string();
    let invoice = bolt11.to_string();

    return Ok(MyInvoice {
        amount: amount,
        description: "Testing".to_string(),
        // description: bolt11.description().to_owned().to_string(),
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
