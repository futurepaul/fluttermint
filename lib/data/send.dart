import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import '../client.dart';

@immutable
class Send {
  const Send(
      {required this.description,
      required this.amountSats,
      required this.invoice,
      this.fee});

  final String description;
  final int amountSats;
  final String invoice;
  final int? fee;

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Send copyWith(
      {String? description, int? amountSats, String? invoice, int? fee}) {
    return Send(
      description: description ?? this.description,
      amountSats: amountSats ?? this.amountSats,
      invoice: invoice ?? this.invoice,
      fee: fee ?? this.fee,
    );
  }
}

class SendNotifier extends StateNotifier<Send?> {
  SendNotifier() : super(null);

  createSend(Send send) async {
    final fee = await api.calculateFee(bolt11: send.invoice);
    state = send.copyWith(invoice: send.invoice, fee: fee ?? 0);
  }

  pay(Send send) async {
    await api.pay(bolt11: send.invoice);
    state = null;
  }

  clear() {
    state = null;
  }
}

final sendProvider = StateNotifierProvider<SendNotifier, Send?>((ref) {
  return SendNotifier();
});
