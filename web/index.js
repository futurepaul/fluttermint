import initWasm, { WasmClient, decode_invoice } from "./pkg/minimint_bridge.js";
export class WasmBridge {
    constructor() {
        this.client = undefined;
    }
    // return true if user has joined federation
    async init() {
        return false;
    }
    async joinFederation(cfg) {
        this.client = await WasmClient.join_federation(cfg);
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
// start loading wasm as soon as possible
const wasmPromise = initWasm();
async function load() {
    // Download main.dart.js
    console.log("loading");
    const appRunnerPromise = globalThis._flutter.loader.loadEntrypoint({
        serviceWorker: {
            serviceWorkerVersion: globalThis.serviceWorkerVersion,
        }
    }).then(engineInitializer => engineInitializer.initializeEngine());
    await wasmPromise;
    globalThis.wasmBridge = new WasmBridge();
    const appRunner = await appRunnerPromise;
    await appRunner.runApp();
}
window.addEventListener('load', load);
