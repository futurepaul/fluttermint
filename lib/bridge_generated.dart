// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports

import 'dart:convert';
import 'dart:typed_data';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'dart:ffi' as ffi;

abstract class MinimintBridge {
  Future<ConnectionStatus> init({required String path, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kInitConstMeta;

  Future<void> joinFederation({required String configUrl, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kJoinFederationConstMeta;

  /// Unset client and wipe database. Ecash will be destroyed. Use with caution!!!
  Future<void> leaveFederation({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kLeaveFederationConstMeta;

  Future<int> balance({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kBalanceConstMeta;

  Future<void> pay({required String bolt11, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kPayConstMeta;

  Future<BridgeInvoice> decodeInvoice({required String bolt11, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kDecodeInvoiceConstMeta;

  Future<String> invoice(
      {required int amount, required String description, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kInvoiceConstMeta;

  Future<BridgePayment> fetchPayment(
      {required String paymentHash, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kFetchPaymentConstMeta;

  Future<List<BridgePayment>> listPayments({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kListPaymentsConstMeta;

  Future<bool> configuredStatus({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kConfiguredStatusConstMeta;

  Future<ConnectionStatus> connectionStatus({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kConnectionStatusConstMeta;

  Future<String> network({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kNetworkConstMeta;

  Future<int?> calculateFee({required String bolt11, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kCalculateFeeConstMeta;

  /// Returns the federations we're members of
  ///
  /// At most one will be `active`
  Future<List<BridgeFederationInfo>> listFederations({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kListFederationsConstMeta;

  /// Switch to a federation that we've already joined
  ///
  /// This assumes federation config is already saved locally
  Future<void> switchFederation(
      {required BridgeFederationInfo federation, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSwitchFederationConstMeta;
}

/// Bridge representation of a fedimint node
class BridgeFederationInfo {
  final String name;
  final String network;
  final bool current;
  final List<BridgeGuardianInfo> guardians;

  BridgeFederationInfo({
    required this.name,
    required this.network,
    required this.current,
    required this.guardians,
  });
}

/// Bridge representation of a fedimint node
class BridgeGuardianInfo {
  final String name;
  final String address;
  final bool online;

  BridgeGuardianInfo({
    required this.name,
    required this.address,
    required this.online,
  });
}

class BridgeInvoice {
  final String paymentHash;
  final int amount;
  final String description;
  final String invoice;

  BridgeInvoice({
    required this.paymentHash,
    required this.amount,
    required this.description,
    required this.invoice,
  });
}

class BridgePayment {
  final BridgeInvoice invoice;
  final PaymentStatus status;
  final int createdAt;
  final bool paid;
  final PaymentDirection direction;

  BridgePayment({
    required this.invoice,
    required this.status,
    required this.createdAt,
    required this.paid,
    required this.direction,
  });
}

enum ConnectionStatus {
  NotConfigured,
  NotConnected,
  Connected,
}

enum PaymentDirection {
  Outgoing,
  Incoming,
}

enum PaymentStatus {
  Paid,
  Pending,
  Failed,
  Expired,
}

class MinimintBridgeImpl extends FlutterRustBridgeBase<MinimintBridgeWire>
    implements MinimintBridge {
  factory MinimintBridgeImpl(ffi.DynamicLibrary dylib) =>
      MinimintBridgeImpl.raw(MinimintBridgeWire(dylib));

  MinimintBridgeImpl.raw(MinimintBridgeWire inner) : super(inner);

  Future<ConnectionStatus> init({required String path, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_init(port_, _api2wire_String(path)),
        parseSuccessData: _wire2api_connection_status,
        constMeta: kInitConstMeta,
        argValues: [path],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kInitConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "init",
        argNames: ["path"],
      );

  Future<void> joinFederation({required String configUrl, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_join_federation(port_, _api2wire_String(configUrl)),
        parseSuccessData: _wire2api_unit,
        constMeta: kJoinFederationConstMeta,
        argValues: [configUrl],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kJoinFederationConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "join_federation",
        argNames: ["configUrl"],
      );

  Future<void> leaveFederation({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_leave_federation(port_),
        parseSuccessData: _wire2api_unit,
        constMeta: kLeaveFederationConstMeta,
        argValues: [],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kLeaveFederationConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "leave_federation",
        argNames: [],
      );

  Future<int> balance({dynamic hint}) => executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_balance(port_),
        parseSuccessData: _wire2api_u64,
        constMeta: kBalanceConstMeta,
        argValues: [],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kBalanceConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "balance",
        argNames: [],
      );

  Future<void> pay({required String bolt11, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_pay(port_, _api2wire_String(bolt11)),
        parseSuccessData: _wire2api_unit,
        constMeta: kPayConstMeta,
        argValues: [bolt11],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kPayConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "pay",
        argNames: ["bolt11"],
      );

  Future<BridgeInvoice> decodeInvoice({required String bolt11, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_decode_invoice(port_, _api2wire_String(bolt11)),
        parseSuccessData: _wire2api_bridge_invoice,
        constMeta: kDecodeInvoiceConstMeta,
        argValues: [bolt11],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kDecodeInvoiceConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "decode_invoice",
        argNames: ["bolt11"],
      );

  Future<String> invoice(
          {required int amount, required String description, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_invoice(
            port_, _api2wire_u64(amount), _api2wire_String(description)),
        parseSuccessData: _wire2api_String,
        constMeta: kInvoiceConstMeta,
        argValues: [amount, description],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kInvoiceConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "invoice",
        argNames: ["amount", "description"],
      );

  Future<BridgePayment> fetchPayment(
          {required String paymentHash, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_fetch_payment(port_, _api2wire_String(paymentHash)),
        parseSuccessData: _wire2api_bridge_payment,
        constMeta: kFetchPaymentConstMeta,
        argValues: [paymentHash],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kFetchPaymentConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "fetch_payment",
        argNames: ["paymentHash"],
      );

  Future<List<BridgePayment>> listPayments({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_list_payments(port_),
        parseSuccessData: _wire2api_list_bridge_payment,
        constMeta: kListPaymentsConstMeta,
        argValues: [],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kListPaymentsConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "list_payments",
        argNames: [],
      );

  Future<bool> configuredStatus({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_configured_status(port_),
        parseSuccessData: _wire2api_bool,
        constMeta: kConfiguredStatusConstMeta,
        argValues: [],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kConfiguredStatusConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "configured_status",
        argNames: [],
      );

  Future<ConnectionStatus> connectionStatus({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_connection_status(port_),
        parseSuccessData: _wire2api_connection_status,
        constMeta: kConnectionStatusConstMeta,
        argValues: [],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kConnectionStatusConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "connection_status",
        argNames: [],
      );

  Future<String> network({dynamic hint}) => executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_network(port_),
        parseSuccessData: _wire2api_String,
        constMeta: kNetworkConstMeta,
        argValues: [],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kNetworkConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "network",
        argNames: [],
      );

  Future<int?> calculateFee({required String bolt11, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_calculate_fee(port_, _api2wire_String(bolt11)),
        parseSuccessData: _wire2api_opt_box_autoadd_u64,
        constMeta: kCalculateFeeConstMeta,
        argValues: [bolt11],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kCalculateFeeConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "calculate_fee",
        argNames: ["bolt11"],
      );

  Future<List<BridgeFederationInfo>> listFederations({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_list_federations(port_),
        parseSuccessData: _wire2api_list_bridge_federation_info,
        constMeta: kListFederationsConstMeta,
        argValues: [],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kListFederationsConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "list_federations",
        argNames: [],
      );

  Future<void> switchFederation(
          {required BridgeFederationInfo federation, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_switch_federation(
            port_, _api2wire_box_autoadd_bridge_federation_info(federation)),
        parseSuccessData: _wire2api_unit,
        constMeta: kSwitchFederationConstMeta,
        argValues: [federation],
        hint: hint,
      ));

  FlutterRustBridgeTaskConstMeta get kSwitchFederationConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "switch_federation",
        argNames: ["federation"],
      );

  // Section: api2wire
  ffi.Pointer<wire_uint_8_list> _api2wire_String(String raw) {
    return _api2wire_uint_8_list(utf8.encoder.convert(raw));
  }

  bool _api2wire_bool(bool raw) {
    return raw;
  }

  ffi.Pointer<wire_BridgeFederationInfo>
      _api2wire_box_autoadd_bridge_federation_info(BridgeFederationInfo raw) {
    final ptr = inner.new_box_autoadd_bridge_federation_info_0();
    _api_fill_to_wire_bridge_federation_info(raw, ptr.ref);
    return ptr;
  }

  ffi.Pointer<wire_list_bridge_guardian_info>
      _api2wire_list_bridge_guardian_info(List<BridgeGuardianInfo> raw) {
    final ans = inner.new_list_bridge_guardian_info_0(raw.length);
    for (var i = 0; i < raw.length; ++i) {
      _api_fill_to_wire_bridge_guardian_info(raw[i], ans.ref.ptr[i]);
    }
    return ans;
  }

  int _api2wire_u64(int raw) {
    return raw;
  }

  int _api2wire_u8(int raw) {
    return raw;
  }

  ffi.Pointer<wire_uint_8_list> _api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list_0(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

  // Section: api_fill_to_wire

  void _api_fill_to_wire_box_autoadd_bridge_federation_info(
      BridgeFederationInfo apiObj,
      ffi.Pointer<wire_BridgeFederationInfo> wireObj) {
    _api_fill_to_wire_bridge_federation_info(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_bridge_federation_info(
      BridgeFederationInfo apiObj, wire_BridgeFederationInfo wireObj) {
    wireObj.name = _api2wire_String(apiObj.name);
    wireObj.network = _api2wire_String(apiObj.network);
    wireObj.current = _api2wire_bool(apiObj.current);
    wireObj.guardians = _api2wire_list_bridge_guardian_info(apiObj.guardians);
  }

  void _api_fill_to_wire_bridge_guardian_info(
      BridgeGuardianInfo apiObj, wire_BridgeGuardianInfo wireObj) {
    wireObj.name = _api2wire_String(apiObj.name);
    wireObj.address = _api2wire_String(apiObj.address);
    wireObj.online = _api2wire_bool(apiObj.online);
  }
}

// Section: wire2api
String _wire2api_String(dynamic raw) {
  return raw as String;
}

bool _wire2api_bool(dynamic raw) {
  return raw as bool;
}

int _wire2api_box_autoadd_u64(dynamic raw) {
  return raw as int;
}

BridgeFederationInfo _wire2api_bridge_federation_info(dynamic raw) {
  final arr = raw as List<dynamic>;
  if (arr.length != 4)
    throw Exception('unexpected arr length: expect 4 but see ${arr.length}');
  return BridgeFederationInfo(
    name: _wire2api_String(arr[0]),
    network: _wire2api_String(arr[1]),
    current: _wire2api_bool(arr[2]),
    guardians: _wire2api_list_bridge_guardian_info(arr[3]),
  );
}

BridgeGuardianInfo _wire2api_bridge_guardian_info(dynamic raw) {
  final arr = raw as List<dynamic>;
  if (arr.length != 3)
    throw Exception('unexpected arr length: expect 3 but see ${arr.length}');
  return BridgeGuardianInfo(
    name: _wire2api_String(arr[0]),
    address: _wire2api_String(arr[1]),
    online: _wire2api_bool(arr[2]),
  );
}

BridgeInvoice _wire2api_bridge_invoice(dynamic raw) {
  final arr = raw as List<dynamic>;
  if (arr.length != 4)
    throw Exception('unexpected arr length: expect 4 but see ${arr.length}');
  return BridgeInvoice(
    paymentHash: _wire2api_String(arr[0]),
    amount: _wire2api_u64(arr[1]),
    description: _wire2api_String(arr[2]),
    invoice: _wire2api_String(arr[3]),
  );
}

BridgePayment _wire2api_bridge_payment(dynamic raw) {
  final arr = raw as List<dynamic>;
  if (arr.length != 5)
    throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
  return BridgePayment(
    invoice: _wire2api_bridge_invoice(arr[0]),
    status: _wire2api_payment_status(arr[1]),
    createdAt: _wire2api_u64(arr[2]),
    paid: _wire2api_bool(arr[3]),
    direction: _wire2api_payment_direction(arr[4]),
  );
}

ConnectionStatus _wire2api_connection_status(dynamic raw) {
  return ConnectionStatus.values[raw];
}

int _wire2api_i32(dynamic raw) {
  return raw as int;
}

List<BridgeFederationInfo> _wire2api_list_bridge_federation_info(dynamic raw) {
  return (raw as List<dynamic>).map(_wire2api_bridge_federation_info).toList();
}

List<BridgeGuardianInfo> _wire2api_list_bridge_guardian_info(dynamic raw) {
  return (raw as List<dynamic>).map(_wire2api_bridge_guardian_info).toList();
}

List<BridgePayment> _wire2api_list_bridge_payment(dynamic raw) {
  return (raw as List<dynamic>).map(_wire2api_bridge_payment).toList();
}

int? _wire2api_opt_box_autoadd_u64(dynamic raw) {
  return raw == null ? null : _wire2api_box_autoadd_u64(raw);
}

PaymentDirection _wire2api_payment_direction(dynamic raw) {
  return PaymentDirection.values[raw];
}

PaymentStatus _wire2api_payment_status(dynamic raw) {
  return PaymentStatus.values[raw];
}

int _wire2api_u64(dynamic raw) {
  return raw as int;
}

int _wire2api_u8(dynamic raw) {
  return raw as int;
}

Uint8List _wire2api_uint_8_list(dynamic raw) {
  return raw as Uint8List;
}

void _wire2api_unit(dynamic raw) {
  return;
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.

/// generated by flutter_rust_bridge
class MinimintBridgeWire implements FlutterRustBridgeWireBase {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  MinimintBridgeWire(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  MinimintBridgeWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void wire_init(
    int port_,
    ffi.Pointer<wire_uint_8_list> path,
  ) {
    return _wire_init(
      port_,
      path,
    );
  }

  late final _wire_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>('wire_init');
  late final _wire_init = _wire_initPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_join_federation(
    int port_,
    ffi.Pointer<wire_uint_8_list> config_url,
  ) {
    return _wire_join_federation(
      port_,
      config_url,
    );
  }

  late final _wire_join_federationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64,
              ffi.Pointer<wire_uint_8_list>)>>('wire_join_federation');
  late final _wire_join_federation = _wire_join_federationPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_leave_federation(
    int port_,
  ) {
    return _wire_leave_federation(
      port_,
    );
  }

  late final _wire_leave_federationPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_leave_federation');
  late final _wire_leave_federation =
      _wire_leave_federationPtr.asFunction<void Function(int)>();

  void wire_balance(
    int port_,
  ) {
    return _wire_balance(
      port_,
    );
  }

  late final _wire_balancePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>('wire_balance');
  late final _wire_balance = _wire_balancePtr.asFunction<void Function(int)>();

  void wire_pay(
    int port_,
    ffi.Pointer<wire_uint_8_list> bolt11,
  ) {
    return _wire_pay(
      port_,
      bolt11,
    );
  }

  late final _wire_payPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>('wire_pay');
  late final _wire_pay = _wire_payPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_decode_invoice(
    int port_,
    ffi.Pointer<wire_uint_8_list> bolt11,
  ) {
    return _wire_decode_invoice(
      port_,
      bolt11,
    );
  }

  late final _wire_decode_invoicePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64,
              ffi.Pointer<wire_uint_8_list>)>>('wire_decode_invoice');
  late final _wire_decode_invoice = _wire_decode_invoicePtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_invoice(
    int port_,
    int amount,
    ffi.Pointer<wire_uint_8_list> description,
  ) {
    return _wire_invoice(
      port_,
      amount,
      description,
    );
  }

  late final _wire_invoicePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Uint64,
              ffi.Pointer<wire_uint_8_list>)>>('wire_invoice');
  late final _wire_invoice = _wire_invoicePtr
      .asFunction<void Function(int, int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_fetch_payment(
    int port_,
    ffi.Pointer<wire_uint_8_list> payment_hash,
  ) {
    return _wire_fetch_payment(
      port_,
      payment_hash,
    );
  }

  late final _wire_fetch_paymentPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>('wire_fetch_payment');
  late final _wire_fetch_payment = _wire_fetch_paymentPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_list_payments(
    int port_,
  ) {
    return _wire_list_payments(
      port_,
    );
  }

  late final _wire_list_paymentsPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_list_payments');
  late final _wire_list_payments =
      _wire_list_paymentsPtr.asFunction<void Function(int)>();

  void wire_configured_status(
    int port_,
  ) {
    return _wire_configured_status(
      port_,
    );
  }

  late final _wire_configured_statusPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_configured_status');
  late final _wire_configured_status =
      _wire_configured_statusPtr.asFunction<void Function(int)>();

  void wire_connection_status(
    int port_,
  ) {
    return _wire_connection_status(
      port_,
    );
  }

  late final _wire_connection_statusPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_connection_status');
  late final _wire_connection_status =
      _wire_connection_statusPtr.asFunction<void Function(int)>();

  void wire_network(
    int port_,
  ) {
    return _wire_network(
      port_,
    );
  }

  late final _wire_networkPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>('wire_network');
  late final _wire_network = _wire_networkPtr.asFunction<void Function(int)>();

  void wire_calculate_fee(
    int port_,
    ffi.Pointer<wire_uint_8_list> bolt11,
  ) {
    return _wire_calculate_fee(
      port_,
      bolt11,
    );
  }

  late final _wire_calculate_feePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>('wire_calculate_fee');
  late final _wire_calculate_fee = _wire_calculate_feePtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_list_federations(
    int port_,
  ) {
    return _wire_list_federations(
      port_,
    );
  }

  late final _wire_list_federationsPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_list_federations');
  late final _wire_list_federations =
      _wire_list_federationsPtr.asFunction<void Function(int)>();

  void wire_switch_federation(
    int port_,
    ffi.Pointer<wire_BridgeFederationInfo> federation,
  ) {
    return _wire_switch_federation(
      port_,
      federation,
    );
  }

  late final _wire_switch_federationPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Int64, ffi.Pointer<wire_BridgeFederationInfo>)>>(
      'wire_switch_federation');
  late final _wire_switch_federation = _wire_switch_federationPtr
      .asFunction<void Function(int, ffi.Pointer<wire_BridgeFederationInfo>)>();

  ffi.Pointer<wire_BridgeFederationInfo>
      new_box_autoadd_bridge_federation_info_0() {
    return _new_box_autoadd_bridge_federation_info_0();
  }

  late final _new_box_autoadd_bridge_federation_info_0Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_BridgeFederationInfo>
              Function()>>('new_box_autoadd_bridge_federation_info_0');
  late final _new_box_autoadd_bridge_federation_info_0 =
      _new_box_autoadd_bridge_federation_info_0Ptr
          .asFunction<ffi.Pointer<wire_BridgeFederationInfo> Function()>();

  ffi.Pointer<wire_list_bridge_guardian_info> new_list_bridge_guardian_info_0(
    int len,
  ) {
    return _new_list_bridge_guardian_info_0(
      len,
    );
  }

  late final _new_list_bridge_guardian_info_0Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_list_bridge_guardian_info> Function(
              ffi.Int32)>>('new_list_bridge_guardian_info_0');
  late final _new_list_bridge_guardian_info_0 =
      _new_list_bridge_guardian_info_0Ptr.asFunction<
          ffi.Pointer<wire_list_bridge_guardian_info> Function(int)>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list_0(
    int len,
  ) {
    return _new_uint_8_list_0(
      len,
    );
  }

  late final _new_uint_8_list_0Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_uint_8_list> Function(
              ffi.Int32)>>('new_uint_8_list_0');
  late final _new_uint_8_list_0 = _new_uint_8_list_0Ptr
      .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void free_WireSyncReturnStruct(
    WireSyncReturnStruct val,
  ) {
    return _free_WireSyncReturnStruct(
      val,
    );
  }

  late final _free_WireSyncReturnStructPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturnStruct)>>(
          'free_WireSyncReturnStruct');
  late final _free_WireSyncReturnStruct = _free_WireSyncReturnStructPtr
      .asFunction<void Function(WireSyncReturnStruct)>();

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>(
          'store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr
      .asFunction<void Function(DartPostCObjectFnType)>();
}

class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

class wire_BridgeGuardianInfo extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> name;

  external ffi.Pointer<wire_uint_8_list> address;

  @ffi.Bool()
  external bool online;
}

class wire_list_bridge_guardian_info extends ffi.Struct {
  external ffi.Pointer<wire_BridgeGuardianInfo> ptr;

  @ffi.Int32()
  external int len;
}

class wire_BridgeFederationInfo extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> name;

  external ffi.Pointer<wire_uint_8_list> network;

  @ffi.Bool()
  external bool current;

  external ffi.Pointer<wire_list_bridge_guardian_info> guardians;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<ffi.Bool Function(DartPort, ffi.Pointer<ffi.Void>)>>;
typedef DartPort = ffi.Int64;
