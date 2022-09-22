import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/balance.dart';

// FIXME: How do we get a initial value
final balanceStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  Stream<String?> getBalance() async* {
    var shouldPoll = true;
    await ref.read(balanceProvider.notifier).refreshBalance();
    while (shouldPoll) {
      try {
        await Future.delayed(const Duration(seconds: 1));
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
    required this.initialBalance,
    Key? key,
  }) : super(key: key);

  final Balance initialBalance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final balanceNotifier = ref.watch(balanceProvider.notifier);
    final balanceStreamWatcher = ref.watch(balanceStreamProvider);

    return GestureDetector(
      onTap: () => {balanceNotifier.switchDenom()},
      child: balanceStreamWatcher.when(
          data: (_) => ActualBalanceDisplay(
              balance: balance ?? const Balance(amountSats: 0)),
          loading: () => ActualBalanceDisplay(
                balance: initialBalance,
              ),
          error: (err, _) => Text(err.toString())),
    );
  }
}

class ActualBalanceDisplay extends StatelessWidget {
  const ActualBalanceDisplay({
    Key? key,
    required this.balance,
  }) : super(key: key);

  final Balance balance;

  @override
  Widget build(BuildContext context) {
    final biggestText = Theme.of(context).textTheme.headline1;
    final bigText =
        Theme.of(context).textTheme.headline1?.copyWith(fontSize: 44);
    final smallText = Theme.of(context).textTheme.headline2;
    return Column(
      children: [
        Text(balance.prettyPrint(),
            style: balance.denomination == Denom.sats ? biggestText : bigText),
        Text(balance.denomination.toReadableString(), style: smallText),
      ],
    );
  }
}
