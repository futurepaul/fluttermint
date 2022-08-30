import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class Transaction {
  const Transaction(
      {required this.description,
      required this.amountSats,
      required this.invoice,
      required this.when});

  final String description;
  final int amountSats;
  final String invoice;
  final String when;
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

  addTransactions(Transaction tx) async {
    state = state.append(tx);
  }

  clear() {
    state = [] as Transactions;
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, Transactions>((ref) {
  return TransactionsNotifier();
});
