import 'package:flutter/foundation.dart';
import 'package:fluttermint/client.dart';
import 'package:riverpod/riverpod.dart';

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
    final payments = await api.fetchPayments();
    for (var payment in payments) {
      debugPrint(payment.toString());
    }
    // state = Balance(amountSats: await api.balance());
  }

  clear() {
    state = [] as Transactions;
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, Transactions>((ref) {
  return TransactionsNotifier();
});
