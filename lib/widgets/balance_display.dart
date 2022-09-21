import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/balance.dart';

final balanceStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  Stream<String?> getBalance() async* {
    var shouldPoll = true;
    while (shouldPoll) {
      try {
        await Future.delayed(const Duration(seconds: 5));
        await ref.read(balanceProvider.notifier).refreshBalance();
        yield "good";
      } catch (e) {
        yield null;
      }
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
    final balance = ref.watch(balanceProvider);
    final balanceNotifier = ref.watch(balanceProvider.notifier);
    final balanceStreamWatcher = ref.watch(balanceStreamProvider);

    final biggestText = Theme.of(context).textTheme.headline1;
    final bigText =
        Theme.of(context).textTheme.headline1?.copyWith(fontSize: 44);
    final smallText = Theme.of(context).textTheme.headline2;

    ref.listen<Balance?>(balanceProvider, (_, balance) {
      if (balance != null) {
        debugPrint("balance: ${balance.amountSats.toString()}");
      } else {
        debugPrint("balance is null?");
      }
    });

    return GestureDetector(
      onTap: () => {balanceNotifier.switchDenom()},
      child: balanceStreamWatcher.when(
          data: (_) => Column(
                children: [
                  Text(balance != null ? balance.prettyPrint() : "",
                      style: balance?.denomination == Denom.sats
                          ? biggestText
                          : bigText),
                  Text(
                      balance != null
                          ? balance.denomination.toReadableString()
                          : "SATS",
                      style: smallText),
                ],
              ),
          loading: () => const SizedBox(height: 0),
          error: (err, _) => Text(err.toString())),
    );
  }
}
