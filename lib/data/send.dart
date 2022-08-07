import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import '../client.dart';

@immutable
class Send {
  const Send(
      {required this.description, required this.amountSats, this.invoice});

  final String description;
  final int amountSats;
  final String? invoice;

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Send copyWith({String? description, int? amountSats, String? invoice}) {
    return Send(
      description: description ?? this.description,
      amountSats: amountSats ?? this.amountSats,
      invoice: invoice ?? this.invoice,
    );
  }
}

class SendNotifier extends StateNotifier<Send?> {
  SendNotifier() : super(null);

  createSend(Send send) async {
    state = send.copyWith(invoice: send.invoice);
  }

  pay(Send send) async {
    if (send.invoice != null) {
      await api.pay(bolt11: send.invoice!);
    }
  }

  clear() {
    state = null;
  }
}

final sendProvider = StateNotifierProvider<SendNotifier, Send?>((ref) {
  return SendNotifier();
});
