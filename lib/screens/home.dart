import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/client.dart';
import 'package:fluttermint/data/balance.dart';
import 'package:fluttermint/utils/connection_status.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/utils/network_detector_notifier.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/not_connected_warning.dart';

import 'package:fluttermint/widgets/textured.dart';
import 'package:fluttermint/widgets/transaction_list.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/balance_display.dart';
import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/logo_action.dart';

final bitcoinNetworkProvider = StreamProvider<String>((_) async* {
  yield await api.network();
});

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final network = ref.watch(networkAwareProvider);
    final balance = ref.watch(balanceProvider);
    final connection = ref.watch(connectionStreamProvider);

    final AsyncValue<String> bitcoinNetwork = ref.watch(bitcoinNetworkProvider);

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
                      const Text('Oops, something unexpected happened'),
                  data: (value) => Text('(on $value)'),
                )
              ],
            ),
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                connection.when(
                  loading: () => Column(
                    children: const [CircularProgressIndicator(), spacer24],
                  ),
                  error: (error, stack) => const NotConnectedWarning(),
                  data: (value) => NotConnectedWarning(
                    networkStatus: network,
                    connectionStatus: value,
                  ),
                ),
                const BalanceDisplay(),
                spacer24,
                const TransactionsList(),
                spacer24,
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlineGradientButton(
                            text: "Receive",
                            disabled:
                                network == NetworkStatus.Off || balance == null,
                            onTap: () {
                              context.go("/receive");
                            }),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: OutlineGradientButton(
                            text: "Send",
                            // If we have a balance, and that balance is greater than 0, and we're connected to the internet
                            disabled: balance != null
                                ? balance.amountSats > 0
                                    ? network != NetworkStatus.Off
                                        ? false
                                        : true
                                    : true
                                : true,
                            onTap: () {
                              context.go("/send");
                            }),
                      ),
                    ])
              ],
            ),
          )),
    );
  }
}
