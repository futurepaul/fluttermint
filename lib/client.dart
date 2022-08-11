import 'ffi.dart' if (dart.library.html) 'wasm.dart';

abstract class MinimintClient {
  /// If this returns Some, user has joined a federation. Otherwise they haven't.
  Future<bool> init();

  Future<void> joinFederation({required String configUrl});

  Future<void> leaveFederation();

  Future<int> balance();

  Future<String> pay({required String bolt11});

  Future<String> decodeInvoice({required String bolt11});

  Future<String> invoice({required int amount});
}

late final MinimintClient api = MinimintClientImpl();
