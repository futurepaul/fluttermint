import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import '../ffi.dart';

@immutable
class Receive {
  const Receive(
      {required this.description, required this.amountSats, this.invoice});

  final String description;
  final int amountSats;
  final String? invoice;

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Receive copyWith({String? description, int? amountSats, String? invoice}) {
    return Receive(
      description: description ?? this.description,
      amountSats: amountSats ?? this.amountSats,
      invoice: invoice ?? this.invoice,
    );
  }
}

class ReceiveNotifier extends StateNotifier<Receive?> {
  ReceiveNotifier() : super(null);

  createReceive(Receive receive) async {
    state = receive.copyWith(
        invoice: await api.invoice(
            amount: receive.amountSats, description: receive.description));
  }

  clear() {
    state = null;
  }
}

final receiveProvider = StateNotifierProvider<ReceiveNotifier, Receive?>((ref) {
  return ReceiveNotifier();
});
