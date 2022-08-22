import initWasm, { WasmClient, WasmDb, init_, decode_invoice } from "./pkg/minimint_bridge.js";
// start loading wasm as soon as possible
const wasmPromise = initWasm();
export class WasmBridge {
    constructor() {
        this.client = undefined;
        // TODO: use this for more than one federations
        this.db = undefined;
    }
    async _init() {
        this.db = await WasmDb.load("fedimint");
        document.addEventListener("visibilitychange", () => {
            // save database on hidden visibility
            if (document.visibilityState == "hidden") {
                // NOTE: no need to await, js promises execute without await
                this.db.save();
            }
        });
        // db.clone(), yay rust like js
        this.client = await init_(this.db.clone());
    }
    // return true if user has joined federation
    async init() {
        return this.client !== undefined;
    }
    async joinFederation(configUrl) {
        this.client = await WasmClient.join_federation(this.db.clone(), configUrl);
    }
    async leaveFederation() {
        // TODO
    }
    async balance() {
        return this.client.balance();
    }
    decodeInvoice(invoice) {
        return decode_invoice(invoice);
    }
    async invoice(amount, description) {
        return await this.client.invoice(amount, description);
    }
    async pay(bolt11) {
        return await this.client.pay(bolt11);
    }
}
async function main() {
    await wasmPromise;
    globalThis.wasmBridge = new WasmBridge();
    // flutter is kind of weird
    await globalThis.wasmBridge._init();
}
const mainPromise = main();
async function load() {
    await mainPromise;
    // Download main.dart.js
    console.log("loading");
    const appRunnerPromise = globalThis._flutter.loader.loadEntrypoint({
        serviceWorker: {
            serviceWorkerVersion: globalThis.serviceWorkerVersion,
        }
    }).then(engineInitializer => engineInitializer.initializeEngine());
    const appRunner = await appRunnerPromise;
    await appRunner.runApp();
}
window.addEventListener('load', load);
