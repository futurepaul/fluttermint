use std::time::Duration;
use std::{io::Cursor, path::Path, str::FromStr};

use bitcoin::secp256k1::schnorrsig::KeyPair;
use lightning_invoice::Invoice;
use minimint::modules::ln::contracts::ContractId;
use minimint::modules::wallet::txoproof::TxOutProof;
use minimint_api::{encoding::Decodable, OutPoint};
use mint_client::{ClientAndGatewayConfig, UserClient};

use anyhow::{anyhow, Result};
use bitcoin::{Address, Amount, Txid};
use bitcoincore_rpc::{Auth, RpcApi};
use lazy_static::lazy_static;
use tokio::sync::Mutex;

lazy_static! {
    static ref CLIENT: Mutex<Option<UserClient>> = Mutex::new(None);
}

lazy_static! {
    static ref PAYMENT: Mutex<Option<(KeyPair, Invoice)>> = Mutex::new(None);
}

fn get_host() -> String {
    #[cfg(not(target_os = "android"))]
    let host = "localhost";
    #[cfg(target_os = "android")]
    let host = "10.0.2.2";
    return host.into();
}

// TODO: include json file as "asset" https://stackoverflow.com/a/63653570
// TODO: use host IP https://stackoverflow.com/questions/47372568/how-to-point-to-localhost8000-with-the-dart-http-package-in-flutter
fn get_cfg() -> String {
    let host = get_host();

    const CFG: &'static str = r#"
{
    "client": {
        "api_endpoints": [
        "http://188.166.55.8:6000",
        "http://188.166.55.8:6001",
        "http://188.166.55.8:6002",
        "http://188.166.55.8:6003"
        ],
        "mint": {
        "tbs_pks": {
            "1": "b8ac8e562ef1cb27306bc85b5ed07e989706c876d6f718d5478c8794e2e44eb3d95272beee9684076aad052ba2dbed060ae41987a8c73d034a03c95636582e60c0be78d6e774121c2e71cc64a8ca0aa58302d1a7f10d863858fa2e24e078d96e",
            "10": "a179a40fc2b65c1fcb61a129f8f971feaec5ec26a7a19df1625212a94b33da595390a28b359362f0f333914830f2e1c80bd3281928e4f706629934479c76480115996a337514877081e36fa972fd9c8d63b41f092e5b81316f657c5a886290b9",
            "100": "a191e24704e892c1ef0833513577cf8e0dffcb62682216722bb358817851156b02f12018cfc6df610410a726458242c205e60b1a6db971d8e3d4ba7d309615e09c6b5ef0b78c44ddd20a707a1404d2ab360d7b08e01d5ce2c5d71e2c74d46971",
            "1000": "89202f04d70d80ac844ee9113a992c95d10f8f57e18dcd35a562ea987fbbccd37eff289c1353952eb20d987c6ae72864062e839dada95a631f44f09a98f3577425515af1ca0767fbe4d2e88dac42addd4975fdde05fe688293e2a581f8008b7d",
            "10000": "8f7fcc89b2ab513dcf29a9a6e1463eb07502d322cc08432611fa97741e49be55d706ca0f82c0e9b0b4d6f667b7e2a4601976f20f70e822ec1ece84b6d843a0c34ee245245c2af9ef54e72c3aea88b9694b93d2dd71ca51f66d067fcef529c012",
            "100000": "b219be2f554ee7d2985d043704e94510d7d247218e32727278370b008bf001b175a7330e854ad8e61ce5e20ade50e51a05fbb5a0e874a9e8d2c27730062c450295c13d48aa4e5a7bdee2f6e0e35155a170391d77c15ff2fa90b757fe520b7d0d",
            "1000000": "880be8fddd778bf85be4b72f9583c811e722e34102620e26f251a4f59dd8fdd7d687d44985b4602e252db253f9b2d8ef11ff075f3c18ee4df3b201ebf936d7035cf936c2855fad09d05a1dad22a7d61f709ce5d2e2d0cf6d30008d37aa5c13ce",
            "10000000": "91c688e6c132cd24e504fa8b62834088616d0b971bbedbfa198fdd0a6196b8e0d40942f30e9886d9fb28ec322a04e45a0d4146be45be90cc26a536c96caa216008450dd57f4feb44db523c3ef4229aab648bf07e3307267b601f67be2bbab7bb",
            "100000000": "a4e73fdafcb6ba4b1033cc76134d8e7b7f061ce424953957be807ec7bf4bd202725946f226001d2bc0d56e62f0eb43a7116b41edbcc83b64c06b93a5eb9a2ae52c2be9b64ed1d962e3a8c785df129e32f0bf025ddb18c5b82686765438a399b5",
            "1000000000": "b8756c3ea02ce489a81e05426e3ec8878e97a2e39639b61c9bba36422e7288de388742fc4dac3f99e733d6066b5b6c2214829fc709ee481547ac5d8ffbf2881b19acb1b6e51bf31c848f22b6614295d0fca948e18401cd7801b79ec228eb6d75"
        }
        },
        "wallet": {
        "peg_in_descriptor": "wsh(sortedmulti(3,0369b787bb134f72f627d7f606e8a227e926d86015bc6dd0ad8a62e5b89c8620b8,0314f7dcce8f071ffaa7ba802ad60c1c40c1e09d94cc72b5f3facd146e28ee39e1,0230fadacde33775440be65bfa2c3e4ea02f085ab17572f0f88f15b89dc7ee6660,02698d47177d887823a8a81c559541277fe22bf3dd095c79a0a545c69c99e1d4d9))#afxapxjf",
        "network": "regtest"
        },
        "ln": {
        "threshold_pub_key": [
            179,
            17,
            175,
            108,
            254,
            212,
            212,
            109,
            62,
            11,
            21,
            124,
            61,
            112,
            134,
            12,
            90,
            178,
            10,
            136,
            211,
            45,
            252,
            189,
            1,
            84,
            83,
            0,
            125,
            148,
            34,
            49,
            83,
            40,
            108,
            170,
            136,
            136,
            38,
            195,
            17,
            223,
            46,
            109,
            77,
            191,
            123,
            51
        ]
        },
        "fee_consensus": {
        "fee_coin_spend_abs": 0,
        "fee_peg_in_abs": 500000,
        "fee_coin_issuance_abs": 0,
        "fee_peg_out_abs": 500000,
        "fee_contract_input": 0,
        "fee_contract_output": 0
        }
    },
    "gateway": {
        "mint_pub_key": "87f866af232ee3bc4556ab39906307719e34aa462cb57d45e71a60e62c303547",
        "node_pub_key": "03c13736bb179d16b9e4ef061076d401f90baed5c52e83c66bb4e23cdf4c537aac",
        "api": "http://188.166.55.8:8080"
    }
}
    "#;

    CFG.replace("localhost", &host)
}

fn create_client(user_dir: &str) -> Result<UserClient> {
    let filename = Path::new(&user_dir).join("client.db");
    let db = sled::open(&filename)?.open_tree("mint-client")?;
    let cfg: ClientAndGatewayConfig = serde_json::from_str(&get_cfg())?;
    Ok(UserClient::new(
        cfg.client,
        Box::new(db),
        Default::default(),
    ))
}

#[tokio::main(flavor = "current_thread")]
pub async fn address() -> Result<String> {
    let client = CLIENT.lock().await;
    let mut rng = rand::rngs::OsRng::new()?;
    let addr = client
        .as_ref()
        .ok_or(anyhow!("No client"))?
        .get_new_pegin_address(&mut rng);
    Ok(addr.to_string())
}

#[tokio::main(flavor = "current_thread")]
pub async fn init(path: String) -> Result<()> {
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
            .with_filter(tracing_subscriber::filter::LevelFilter::DEBUG),
        )
        .try_init()
        .unwrap_or_else(|error| tracing::info!("Error installing logger: {}", error));

    let mut client = CLIENT.lock().await;
    *client = Some(create_client(&path)?);
    Ok(())
}

#[tokio::main(flavor = "current_thread")]
pub async fn balance() -> Result<u64> {
    let client = CLIENT.lock().await;
    let amount = client
        .as_ref()
        .ok_or(anyhow!("No client"))?
        .coins()
        .amount();
    Ok(amount.milli_sat)
}

#[tokio::main(flavor = "current_thread")]
pub async fn pegin(txid: String) -> Result<String> {
    let txid: Txid = txid.parse()?;

    let client = CLIENT.lock().await;
    let mut rng = rand::rngs::OsRng::new()?;

    let url = format!("http://{}:18443/wallet/default", get_host());
    let auth = Auth::UserPass("bitcoin".into(), "bitcoin".into());
    let rpc_client = bitcoincore_rpc::Client::new(&url, auth)?;

    let tx = rpc_client.get_raw_transaction(&txid, None)?;
    let _txout_proof = rpc_client.get_tx_out_proof(&[txid], None)?;
    let txout_proof =
        TxOutProof::consensus_decode(Cursor::new(_txout_proof)).map_err(|e| anyhow!("{:?}", e))?;

    let id = client
        .as_ref()
        .ok_or(anyhow!("No client"))?
        .peg_in(txout_proof, tx, &mut rng)
        .await?;

    let outpoint = OutPoint {
        txid: id,
        out_idx: 0,
    };

    loop {
        let result = client
            .as_ref()
            .ok_or(anyhow!("No client"))?
            .fetch_coins(outpoint)
            .await;

        match result {
            Ok(()) => return Ok("ok".to_string()), // FIXME
            Err(err) if err.is_retryable_fetch_coins() => {
                tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
                continue;
            }
            Err(err) => Err(err)?,
        };
    }
}

#[tokio::main(flavor = "current_thread")]
pub async fn pegout(address: String) -> Result<String> {
    let client = CLIENT.lock().await;
    let mut rng = rand::rngs::OsRng::new()?;
    let txid = client
        .as_ref()
        .ok_or(anyhow!("No client"))?
        .peg_out(
            Amount::from_sat(1_000),
            Address::from_str(&address)?,
            &mut rng,
        )
        .await?;
    Ok(format!("{:?}", txid))
}

#[tokio::main(flavor = "current_thread")]
pub async fn pay(bolt11: String) -> Result<String> {
    let cfg: ClientAndGatewayConfig = serde_json::from_str(&get_cfg())?;
    let mut rng = rand::rngs::OsRng::new()?;
    let http = reqwest::Client::new();
    let client_lock = CLIENT.lock().await;
    let client = client_lock.as_ref().ok_or(anyhow!("No client"))?;
    let bolt11: Invoice = bolt11.parse()?;

    let contract_id = client
        .fund_outgoing_ln_contract(&cfg.gateway, bolt11, &mut rng)
        .await
        .expect("Not enough coins");

    client
        .wait_contract_timeout(contract_id, Duration::from_secs(10))
        .await
        .expect("Contract wasn't accepted in time");

    let r = http
        .post(&format!("{}/pay_invoice", cfg.gateway.api))
        .json(&contract_id)
        .timeout(Duration::from_secs(15))
        .send()
        .await
        .unwrap();

    return Ok(format!("{:?}", r));
}

#[tokio::main(flavor = "current_thread")]
pub async fn invoice(amount: u64) -> Result<String> {
    let cfg: ClientAndGatewayConfig = serde_json::from_str(&get_cfg())?;
    let mut rng = rand::rngs::OsRng::new()?;
    let client_lock = CLIENT.lock().await;
    let client = client_lock.as_ref().ok_or(anyhow!("No client"))?;

    // Save the keys and invoice for later polling`
    let amt = minimint_api::Amount::from_sat(amount);
    let (keypair, invoice) = client
        .create_invoice_and_offer(amt, &cfg.gateway, &mut rng)
        .await
        .expect("Couldn't create invoice");

    // we can only receive 1 lightning invoice at-a-time
    let mut payment_guard = PAYMENT.lock().await;
    *payment_guard = Some((keypair, invoice.clone()));

    Ok(invoice.to_string())
}

#[tokio::main(flavor = "current_thread")]
pub async fn claim_incoming_contract() -> Result<()> {
    let rng = rand::rngs::OsRng::new()?;
    let client_guard = CLIENT.lock().await;
    let client = client_guard.as_ref().ok_or(anyhow!("No client"))?;
    let mut payment_guard = PAYMENT.lock().await;
    let (keypair, invoice) = payment_guard.as_ref().ok_or(anyhow!("No payment"))?;

    tracing::info!(
        "fetching incoming contract {:?} {:?}",
        invoice.payment_hash(),
        keypair.clone()
    );
    client
        .claim_incoming_contract(
            ContractId::from_hash(invoice.payment_hash().clone()),
            keypair.clone(),
            rng,
        )
        .await?;

    let balance = client.coins().amount();
    tracing::info!("fetching coins (balance = {:?}", balance.milli_sat);

    // Ecash tokens have been transferred from gateway to user
    client.fetch_all_coins().await.unwrap();

    let balance = client.coins().amount();
    tracing::info!("fetched coins (balance = {:?}", balance.milli_sat);

    // Reset hacky payment info
    *payment_guard = None;

    Ok(())
}
