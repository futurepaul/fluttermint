import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/ffi.dart';
import 'package:fluttermint/data/balance.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/utils/network_detector_notifier.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/logo_action.dart';
import 'package:fluttermint/widgets/not_connected_warning.dart';

import 'package:fluttermint/widgets/textured.dart';
import 'package:fluttermint/widgets/transaction_list.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/balance_display.dart';
import 'package:fluttermint/widgets/content_padding.dart';

final bitcoinNetworkProvider = FutureProvider<String>((_) async {
  return await api.network();
});

// TODO: this is gross but my stream poller is so bad I need it
final balanceOnceProvider = FutureProvider<int>((_) async {
  return await api.balance();
});

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceOnce = ref.watch(balanceOnceProvider);
    final network = ref.watch(networkAwareProvider);

    final showTransactions = ref.watch(showTransactionsProvider);

    // FIXME: annoying to have this value and not be able to update it effectively
    final Balance initialBalance = Balance(amountSats: balanceOnce.value ?? 0);

    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120), // Set this height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                FedimintLogoAction(),
              ],
            ),
          ),
          body: ContentPadding(
            child: showTransactions
                ? HomeTxsOpen(network: network, initialBalance: initialBalance)
                : HomeTxsNotOpen(
                    network: network, initialBalance: initialBalance),
          )),
    );
  }
}

// FIXME: these are really redundant widgets I just wasn't winning at flexbox and this made it simpler to reason about
class HomeTxsOpen extends StatelessWidget {
  const HomeTxsOpen({
    Key? key,
    required this.network,
    required this.initialBalance,
  }) : super(key: key);

  final NetworkStatus network;
  final Balance initialBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NotConnectedWarning(
          networkStatus: network,
        ),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BalanceDisplay(
                small: true,
                initialBalance: initialBalance,
              ),
              spacer24,
              const Expanded(child: TransactionsList()),
            ],
          ),
        ),
        spacer12,
        HomeButtonRow(network: network, initialBalance: initialBalance),
      ],
    );
  }
}

class HomeTxsNotOpen extends StatelessWidget {
  const HomeTxsNotOpen({
    Key? key,
    required this.network,
    required this.initialBalance,
  }) : super(key: key);

  final NetworkStatus network;
  final Balance initialBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        NotConnectedWarning(
          networkStatus: network,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BalanceDisplay(
              initialBalance: initialBalance,
            ),
            spacer24,
            const TransactionsList(),
          ],
        ),
        const Spacer(),
        HomeButtonRow(network: network, initialBalance: initialBalance),
      ],
    );
  }
}

class HomeButtonRow extends ConsumerWidget {
  const HomeButtonRow({
    Key? key,
    required this.network,
    required this.initialBalance,
  }) : super(key: key);

  final NetworkStatus network;
  final Balance initialBalance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
        child: OutlineGradientButton(
            text: "Receive",
            disabled: network == NetworkStatus.Off,
            onTap: () {
              context.go("/receive");
            }),
      ),
      const SizedBox(width: 20.0),
      Expanded(
        child: OutlineGradientButton(
            text: "Send",
            // if balance isn't 0 and we're connected to the internet
            disabled: balance?.amountSats == 0 || network == NetworkStatus.Off,
            onTap: () {
              context.go("/send");
            }),
      ),
    ]);
  }
}
