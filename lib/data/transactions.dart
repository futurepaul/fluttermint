import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';

import 'package:fluttermint/bridge_generated.dart';
import 'package:fluttermint/client.dart';

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

const FAKE_TX = Transaction(
    amountSats: 123,
    description: "heyo",
    invoice: "abc123",
    when: "May 6 - 9:21p",
    status: "Received");

const FAKE_TX_2 = Transaction(
    amountSats: 123000,
    description: "a longer description this time sorry",
    invoice: "abc123",
    when: "October 7 - 12:21a",
    status: "Pending");

Transaction txFromBridgePayment(BridgePayment payment) {
  final when = DateTime.fromMillisecondsSinceEpoch(payment.createdAt * 1000);

  return Transaction(
      description: payment.invoice.description,
      amountSats: payment.invoice.amount,
      invoice: payment.invoice.invoice,
      when: DateFormat.MMMMd().add_jm().format(when),
      status: payment.status.toReadableString());
}

@immutable
class Transaction {
  const Transaction(
      {required this.description,
      required this.amountSats,
      required this.invoice,
      required this.when,
      required this.status});

  final String description;
  final int amountSats;
  final String invoice;
  final String when;
  final String status;
}

@immutable
class Transactions {
  const Transactions(
      [this.txs = const [
        // FAKE_TX_2,
        // FAKE_TX_2,
        // FAKE_TX,
        // FAKE_TX,
        // FAKE_TX,
        // FAKE_TX,
        // FAKE_TX_2,
      ]]);

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
    var payments = await api.fetchPayments();
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
