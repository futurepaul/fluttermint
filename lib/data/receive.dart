import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'dart:convert';

import '../client.dart';

@immutable
class Receive {
  const Receive(
      {required this.description,
      required this.amountSats,
      this.invoice,
      this.receiveStatus});

  final String description;
  final int amountSats;
  final String? invoice;
  final String? receiveStatus;

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Receive copyWith(
      {String? description,
      int? amountSats,
      String? invoice,
      String? receiveStatus}) {
    return Receive(
        description: description ?? this.description,
        amountSats: amountSats ?? this.amountSats,
        invoice: invoice ?? this.invoice,
        receiveStatus: receiveStatus ?? this.receiveStatus);
  }
}

class ReceiveNotifier extends StateNotifier<Receive?> {
  ReceiveNotifier() : super(null);

  createReceive(Receive receive) async {
    state = receive.copyWith(
        invoice: await api.invoice(
            amount: receive.amountSats, description: receive.description));
  }

  checkPaymentStatus() async {
    try {
      final invoice = state?.invoice;
      if (invoice == null) {
        throw Exception("no error for some reason");
      }
      // debugPrint("checking status for ${invoice}");

      var decoded = jsonDecode(await api.decodeInvoice(bolt11: invoice));
      var status = await api.fetchPayment(paymentHash: decoded["paymentHash"]);
      debugPrint(status.paid ? "paid" : "not paid");
      if (status.paid) {
        state = state?.copyWith(receiveStatus: "paid");
      } else {
        state = state?.copyWith(receiveStatus: "pending");
      }

      // state = state?.copyWith(sendStatus: response.status);
    } catch (e) {
      debugPrint('Caught error: $e');
      throw Exception(e.toString());
    }
  }

  clear() {
    state = null;
  }
}

final receiveProvider = StateNotifierProvider<ReceiveNotifier, Receive?>((ref) {
  return ReceiveNotifier();
});
