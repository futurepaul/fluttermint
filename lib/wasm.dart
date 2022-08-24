import "package:js/js.dart";

import "client.dart";
import "wasm_generated.dart";

class MinimintClientImpl implements MinimintClient {
  @override
  Future<bool> init() {
    return wasmBridge.init();
  }

  Future<void> joinFederation({required String userDir, required String configUrl}) {
    return wasmBridge.joinFederation(configUrl);
  }

  @override
  Future<void> leaveFederation() {
    return wasmBridge.leaveFederation();
  }

  @override
  Future<int> balance() async {
    // TODO: check if cast is correct.
    return (await wasmBridge.balance()) as int;
  }

  @override
  Future<String> pay({required String bolt11}) {
    return wasmBridge.pay(bolt11);
  }

  @override
  Future<String> decodeInvoice({required String bolt11}) async {
    return wasmBridge.decodeInvoice(bolt11);
  }

  @override
  Future<String> invoice({required int amount, required String description}) {
    return wasmBridge.invoice(amount);
  }
}
