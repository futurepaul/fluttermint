import initWasm, { WasmClient, decode_invoice } from "./pkg/minimint_bridge.js"

export class WasmBridge {
  private client: WasmClient | undefined = undefined;

  // return true if user has joined federation
  async init(): Promise<boolean> {
    return false;
  }

  async joinFederation(userDir: string, cfg: string): Promise<void> {
    this.client = await WasmClient.join_federation(userDir, cfg);
  }

  async leaveFederation(): Promise<void> {
    // TODO
  }

  async balance(): Promise<number> {
    return this.client.balance();
  }

  decodeInvoice(invoice: string): string {
    return decode_invoice(invoice);
  }

  async invoice(amount: number, description: string): Promise<string> {
    return await this.client.invoice(amount, description);
  }

  async pay(bolt11: string): Promise<string> {
    return await this.client.pay(bolt11);
  }
}

export declare const wasmBridge: WasmBridge;

// start loading wasm as soon as possible
const wasmPromise = initWasm();

async function load() {
  // Download main.dart.js
  console.log("loading")
  const appRunnerPromise = globalThis._flutter.loader.loadEntrypoint({
    serviceWorker: {
      serviceWorkerVersion: globalThis.serviceWorkerVersion,
    }
  }).then(engineInitializer =>
    engineInitializer.initializeEngine()
  );
  await wasmPromise;
  globalThis.wasmBridge = new WasmBridge();
  const appRunner = await appRunnerPromise;
  await appRunner.runApp();
}

window.addEventListener('load', load);
