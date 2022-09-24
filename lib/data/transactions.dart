import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';

import 'package:fluttermint/bridge_generated.dart';
import 'package:fluttermint/ffi.dart';

extension ParseToString on PaymentStatus {
  String toReadableString() {
    switch (this) {
      case PaymentStatus.Expired:
        return "Expired";
      case PaymentStatus.Paid:
        return "Paid";
      case PaymentStatus.Pending:
        return "Pending";
      case PaymentStatus.Failed:
        return "Failed";
    }
  }
}

Transaction txFromBridgePayment(BridgePayment payment) {
  final when = DateTime.fromMillisecondsSinceEpoch(payment.createdAt * 1000);

  return Transaction(
      description: payment.invoice.description,
      amountSats: payment.invoice.amount,
      invoice: payment.invoice.invoice,
      when: DateFormat.MMMMd().add_jm().format(when),
      status: payment.status.toReadableString(),
      direction: payment.direction);
}

@immutable
class Transaction {
  const Transaction(
      {required this.description,
      required this.amountSats,
      required this.invoice,
      required this.when,
      required this.status,
      required this.direction});

  final String description;
  final int amountSats;
  final String invoice;
  final String when;
  final String status;
  final PaymentDirection direction;
}

@immutable
class Transactions {
  const Transactions([this.txs = const []]);

  final List<Transaction> txs;

  Transactions append(Transaction tx) {
    return Transactions([...txs, tx]);
  }
}

class TransactionsNotifier extends StateNotifier<Transactions> {
  TransactionsNotifier() : super(const Transactions());

  addTransaction(Transaction tx) async {
    state = state.append(tx);
  }

  fetchTransactions() async {
    debugPrint("Fetching txs");
    var payments = await api.listPayments();
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    List<Transaction> txs = [];
    for (var payment in payments) {
      txs.add(txFromBridgePayment(payment));
    }
    state = Transactions(txs);
  }

  clear() {
    state = [] as Transactions;
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, Transactions>((ref) {
  return TransactionsNotifier();
});
