import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/balance.dart';

final balanceStreamProvider = StreamProvider.autoDispose<num?>((ref) {
  Stream<num?> getBalance() async* {
    var shouldPoll = true;
    while (shouldPoll) {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint("polling balance");
      await ref.read(balanceProvider.notifier).createBalance();
      yield ref.read(balanceProvider)?.amountSats;
    }
  }

  return getBalance();
});

class BalanceDisplay extends ConsumerWidget {
  const BalanceDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceProvider = ref.watch(balanceStreamProvider);

    return Column(
      children: [
        balanceProvider.when(
            data: (data) => Text(data != null ? "$data" : "???",
                style: Theme.of(context).textTheme.headline1),
            loading: () =>
                Text("~", style: Theme.of(context).textTheme.headline1),
            error: (err, _) => Text(err.toString())),
        Text("SATS", style: Theme.of(context).textTheme.headline2),
      ],
    );
  }
}
