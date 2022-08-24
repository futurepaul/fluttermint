use crate::client::Client;
use std::sync::Arc;

use js_sys::Promise;
use fedimint_api::db::mem_impl::MemDatabase;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsValue;
use wasm_bindgen_futures::future_to_promise;

#[wasm_bindgen]
pub struct WasmClient(Arc<Client>);
type Result<T> = std::result::Result<T, JsValue>;

#[wasm_bindgen(start)]
pub fn start() {
    tracing_wasm::set_as_global_default_with_config(
        tracing_wasm::WASMLayerConfigBuilder::default()
            .set_console_config(tracing_wasm::ConsoleConfig::ReportWithConsoleColor)
            .set_max_level(tracing::Level::INFO)
            .build(),
    );
}

fn anyhow_to_js(error: anyhow::Error) -> JsValue {
    JsValue::from(error.to_string())
}

#[wasm_bindgen]
impl WasmClient {
    #[wasm_bindgen]
    pub async fn join_federation(cfg: String) -> Result<WasmClient> {
        let client = Client::new(Box::new(MemDatabase::new()), &cfg)
            .await
            .map_err(anyhow_to_js)?;

        let client = Arc::new(client);
        let client_poll = client.clone();
        wasm_bindgen_futures::spawn_local(async move {
            client_poll.poll().await;
        });
        Ok(WasmClient(client))
    }

    #[wasm_bindgen]
    pub fn info(&self) {
        let coins = self.0.client.coins();
        tracing::info!(
            "We own {} coins with a total value of {}",
            coins.coin_count(),
            coins.amount()
        );
        for (amount, coins) in coins.coins {
            tracing::info!("We own {} coins of denomination {}", coins.len(), amount);
        }
    }

    #[wasm_bindgen]
    pub fn leave_federation(self) -> Result<()> {
        // delete the database (their ecash tokens will disappear ... this shouldn't be done lightly ...)
        // set CLIENT to None
        Ok(())
    }

    // NOTE: we need to use `Promise` instead of `async` support due to lifetimes.
    #[wasm_bindgen]
    pub fn balance(&self) -> Promise {
        let this = self.0.clone();
        future_to_promise(async move { Ok(JsValue::from(this.balance().await as u32)) })
    }

    #[wasm_bindgen]
    pub fn pay(&self, bolt11: String) -> Promise {
        let this = self.0.clone();
        future_to_promise(async move {
            this.pay(bolt11).await.map_err(anyhow_to_js)?;
            Ok(JsValue::null())
        })
    }

    #[wasm_bindgen]
    // TODO: wasm doesn't like u64
    pub fn invoice(&self, amount: u32, description: String) -> Promise {
        let this = self.0.clone();
        future_to_promise(async move {
            Ok(JsValue::from(
                this.invoice(amount as u64, "example".to_string()).await.map_err(anyhow_to_js)?,
            ))
        })
    }
}

#[wasm_bindgen]
pub fn decode_invoice(bolt11: String) -> Result<String> {
    crate::client::decode_invoice(bolt11).map_err(anyhow_to_js)
}
