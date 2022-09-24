import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/transactions.dart';
import 'package:fluttermint/utils/constants.dart';
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

    return Padding(
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
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black,
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black
                        ],
                        stops: [
                          0.0,
                          0.05,
                          0.95,
                          1.0
                        ]).createShader(bounds);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ListView(shrinkWrap: true, children: [
                    if (transactions.txs.isEmpty) ...[
                      spacer24,
                      const Center(child: Text("No transactions"))
                    ],
                    ...transactions.txs.map((tx) => SingleTx(tx: tx))
                  ]),
                ),
              )
            : const SizedBox.shrink()
      ]),
    );
  }
}
