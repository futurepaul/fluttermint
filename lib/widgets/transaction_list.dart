import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/transactions.dart';

class SingleTransaction extends StatelessWidget {
  const SingleTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TransactionsList extends ConsumerWidget {
  const TransactionsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    // final transactionsNotifier = ref.watch(transactionsProvider.notifier);

    return Column(
      children: [
        const Text("toggle"),
        ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children: transactions.txs.map((tx) => const Text("TX")).toList()),
      ],
    );
  }
}
