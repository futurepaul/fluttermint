import 'ffi.dart' if (dart.library.html) 'wasm.dart';
import 'bridge_generated.dart';

abstract class MinimintClient {
  /// If this returns Some, user has joined a federation. Otherwise they haven't.
  Future<bool> init();

  Future<void> joinFederation({required String configUrl});

  Future<void> leaveFederation();

  Future<int> balance();

  Future<void> pay({required String bolt11});

  Future<String> decodeInvoice({required String bolt11});

  Future<String> invoice({required int amount, required String description});

  Future<BridgePayment> fetchPayment(
      {required String paymentHash, dynamic hint});

  Future<List<BridgePayment>> fetchPayments();
}

final MinimintClient api = MinimintClientImpl();
