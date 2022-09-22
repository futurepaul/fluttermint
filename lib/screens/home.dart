import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/client.dart';
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

final bitcoinNetworkProvider = StreamProvider<String>((_) async* {
  yield await api.network();
});

final balanceProvider = StreamProvider<int>((_) async* {
  yield await api.balance();
});

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final network = ref.watch(networkAwareProvider);
    final bitcoinNetwork = ref.watch(bitcoinNetworkProvider);

    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120), // Set this height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FedimintLogoAction(),
                bitcoinNetwork.when(
                  loading: () => const Text(""),
                  error: (error, stack) =>
                      const Text('Tap here to join a federation'),
                  data: (value) => Text('(on $value)'),
                )
              ],
            ),
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NotConnectedWarning(
                  networkStatus: network,
                ),
                balance.when(
                    data: (data) => BalanceDisplay(
                          initialBalance: Balance(amountSats: data),
                        ),
                    error: (error, stackTrace) => const Text(""),
                    loading: () => const CircularProgressIndicator()),
                spacer24,
                balance.when(
                  data: (data) => const TransactionsList(),
                  error: (error, stackTrace) => spacer12,
                  loading: () => spacer12,
                ),
                spacer24,
                balance.when(
                  data: (data) => HomeButtonRow(network: network, sats: data),
                  error: (error, stackTrace) =>
                      HomeButtonRow(network: network, sats: 0),
                  loading: () => HomeButtonRow(network: network, sats: 0),
                ),
              ],
            ),
          )),
    );
  }
}

class HomeButtonRow extends StatelessWidget {
  const HomeButtonRow({
    Key? key,
    required this.network,
    required this.sats,
  }) : super(key: key);

  final NetworkStatus network;
  final int sats;

  @override
  Widget build(BuildContext context) {
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
            // If we have a balance, and that balance is greater than 0, and we're connected to the internet
            disabled: sats > 0
                ? network != NetworkStatus.Off
                    ? false
                    : true
                : true,
            onTap: () {
              context.go("/send");
            }),
      ),
    ]);
  }
}
