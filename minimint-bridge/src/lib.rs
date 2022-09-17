#[cfg(not(target_family = "wasm"))]
mod api;
#[cfg(not(target_family = "wasm"))]
mod bridge_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
mod client;

#[cfg(target_family = "wasm")]
mod wasm_client;

mod payments;
