import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/balance.dart';

class BalanceDisplay extends ConsumerWidget {
  const BalanceDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final balanceNotifier = ref.watch(balanceProvider.notifier);

    // Fetch initial balance. Is there a better way?
    balanceNotifier.createBalance();

    return Column(
      children: [
        Text(balance != null ? "${balance.amountSats}" : "???",
            style: Theme.of(context).textTheme.headline1),
        Text("SATS", style: Theme.of(context).textTheme.headline2),
      ],
    );
  }
}
