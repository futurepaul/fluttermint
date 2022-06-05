use std::time::Duration;
use std::{io::Cursor, path::Path, str::FromStr};

use lightning_invoice::Invoice;
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
          "http://localhost:8000",
          "http://localhost:8001",
          "http://localhost:8002",
          "http://localhost:8003"
        ],
        "mint": {
          "tbs_pks": {
            "1": "8540633f5f9b8997442290f5a871a78a91cd4090ad7c1179648d57b7ec6b185cc9ad6a4d0608630bc737354e33b9b7880ef02f75c313f3969928a8bf3c51ae699846ece005db635be106475c9f81922dc2bd266ae4c2755ad123a7da93028ec8",
            "10": "a17cad78561fc8b6cc16f245c574f83ec06e0d2097cbfd0982f75949cf06d7b749f1521faf58d3e96abc9e01d49ddd1b1780f601e1ae9691675fbb970f04141cbb3963b1bcb423fd819e9003548c114905abc92794fb66f46856782706e22303",
            "100": "93400d0c5a91274dd77890b19f55d2a3d858276b5fe7123da5b5690b581582a38de6059fc9891213b5fbbd73be48a80705d01d72ad30dfb50c326e11645fd19acf9e4e992557dc591cee191d5634b4bd9647993f30831cc623c47bda1949848e",
            "1000": "ad1964d98ad2f5f0023f9c0dfe78d40e73e80cd2427c925ff2ec24b232b3b24f704b27025bab743b8b08311e395ab2ee0d5afd0939459e7dd4eddf765540dee8ad53cb91c1d72e627d0e589ff624b3dc17b9a40a129466b5f4467e45d3ecbd71",
            "10000": "a7dc67d40e1f33120ac44646d3e138da0703e51a124bfbcd8324ffd9c96c3a7d56f512a6e5b5e4f37ee844ea51f1e1d21073df60f375e9b74d6115dc605f5bd23743d5227c1b1ca9cc90f51109da4f6ef82e926133a6b77802087615d55b03dd",
            "100000": "b76ac7eb4b856240a70708e8796b460903c3e3c12686a6fdb2d19e165f8cc03c1aced8feb8c04374ecbcb77aacde373f145a921af222f490812afcb8b83ffcbfaa47f08f2a687877d04f70affb620e9f9dcddba35e0af60273028f143f821840",
            "1000000": "861f4df30ac01e623bae220eeca5eecb78e656a830ed7f24a2918f3a66e5ac60fd448820c63e68dc5e1a3ee9268eb2a713721607ebdad3129b217faed320c0ee35e0a333713c4102257c1bc503808d3b7ac3444f2e6df649ded255022ef3582d",
            "10000000": "894a505c15e8602fdc96cb3ac1f7d534f25686d1ae6d21eee7fd6691e4dc2774c079fe7c08d8611135430997b05b7b23049678f0ea4c2fa0b78111fab55e43abbc4e117295df9f478ace5267adc44a976de7ee33f1d6dd43cd128afc87eb9e79",
            "100000000": "aea3153df6acd89c86512560770556f72ad6e1b7adb5ff51a26ead6e1f0ddcb0ea06a4e710d0d1bf188e84b32b81c83f080b3768ed2ed388b6fb3d4e2787944d8052035efa860dc53a56e6e11bed5a8726fa7d2663bc43dab7d43d7b01b674ec",
            "1000000000": "89af947ad4a7a5998a55dddda25b3d56292bef2eca9f33f1b02ca6f174e3f94ebd189976db0ef03aa8288b0518378d5312049a703114bdd5196a75ecc8400302d015c99f36fecb070fbc085e931d4a918f0536d3086d2ccf38d78bdbe0152bb7"
          }
        },
        "wallet": {
          "peg_in_descriptor": "wsh(sortedmulti(3,025590fa33ed9ea09700d43484656e883fd1c16911a03a86acfe64b436ece98430,02a1aeb4a3bb8491b88541f6333e5324427894a62b17d748a67fff824637cfb045,0303113864457f1e5153a6925c75a70fcf4f136bab1518f7c755ee61b2f5874f00,02c4ccef1be8c380d8ae753a94e1238ec1dc43aa4e1c0cc9863b8278714750c9e6))#39rv0znw",
          "network": "regtest"
        },
        "ln": {
          "threshold_pub_key": [
            167,
            24,
            124,
            133,
            216,
            220,
            137,
            129,
            81,
            175,
            249,
            19,
            165,
            21,
            89,
            168,
            21,
            182,
            60,
            176,
            189,
            247,
            194,
            205,
            79,
            55,
            22,
            209,
            3,
            10,
            182,
            201,
            171,
            73,
            141,
            115,
            121,
            128,
            235,
            194,
            52,
            231,
            72,
            17,
            75,
            19,
            181,
            95
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
        "mint_pub_key": "05d94b26f700124c109784a02a01ddf8e5415b19746c43f6908158da22858961",
        "node_pub_key": "025efecc04f2ce13a6452488933ba721ed7368702d1ecc67927c9b722f3585893b",
        "api": "http://localhost:8080"
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
