import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/transactions.dart';
import 'package:fluttermint/widgets/single_tx.dart';
import 'package:fluttermint/widgets/toggle.dart';

final showTransactionsProvider = StateProvider<bool>((ref) => false);

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
    final transactionsNotifier = ref.watch(transactionsProvider.notifier);

    final showTransactions = ref.watch(showTransactionsProvider);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(children: [
          Toggle(
              onToggle: () async {
                // TODO: need a more canonical place to do this
                await transactionsNotifier.fetchTransactions();
                ref
                    .read(showTransactionsProvider.notifier)
                    .update((show) => !show);
              },
              active: showTransactions),
          showTransactions
              ? Expanded(
                  child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      children: [
                        if (transactions.txs.isEmpty) ...[
                          const Center(child: Text("No transactions"))
                        ],
                        ...transactions.txs.map((tx) => SingleTx(tx: tx))
                      ]),
                )
              : const SizedBox.shrink()
        ]),
      ),
    );
  }
}
