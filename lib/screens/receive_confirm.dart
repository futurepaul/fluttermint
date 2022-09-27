import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/balance.dart';
import 'package:fluttermint/data/receive.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/balance_display.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/chill_info_card.dart';
import 'package:fluttermint/widgets/qr_display.dart';
import 'package:fluttermint/widgets/transaction_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

import 'package:share_plus/share_plus.dart';

final paymentStatusStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  Stream<String?> getStatus() async* {
    var shouldPoll = true;
    while (shouldPoll) {
      await Future.delayed(const Duration(seconds: 1));
      await ref.read(receiveProvider.notifier).checkPaymentStatus();
      yield "pending";
    }
  }

  return getStatus();
});

class ReceiveConfirm extends ConsumerWidget {
  const ReceiveConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receive = ref.read(receiveProvider);
    final receiveNotifier = ref.read(receiveProvider.notifier);

    final statusProvider = ref.watch(paymentStatusStreamProvider);

    final statusText = statusProvider.when(
        data: (data) => data ?? "error",
        loading: () => "loading",
        error: (err, _) => err.toString());

    // Don't context.go across async boundary
    ref.listen<Receive?>(receiveProvider, (_, receive) {
      if (receive?.receiveStatus == "paid") {
        // TODO: kind of hacky...
        // Toggle transactions closed so they have to refresh it by opening it
        ref.read(showTransactionsProvider.notifier).update((show) => false);
        context.go("/");
      }
    });

    final invoice = receive?.invoice;
    final lightningUri = "lightning:$invoice";
    final desc = receive?.description;
    final amount = receive?.amountSats;

    void _copy() {
      Clipboard.setData(ClipboardData(text: invoice));
      Fluttertoast.showToast(
          msg: "Invoice Copied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: black,
          textColor: white,
          fontSize: 16.0);
    }

    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Receive bitcoin",
            backAction: () {
              context.go("/receive");
            },
            closeAction: () {
              receiveNotifier.clear();
              context.go("/");
            },
          ),
          body: ContentPadding(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ChillInfoCard(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ActualBalanceDisplay(
                              small: true,
                              balance: Balance(amountSats: amount ?? 0),
                            ),
                            spacer12,
                            if (desc != null && desc.isNotEmpty) ...[
                              Column(
                                children: [
                                  Text(desc, style: paymentDescriptionText),
                                  spacer12,
                                ],
                              ),
                            ],
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: white.withOpacity(0.1)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                child: Text(statusText.toUpperCase(),
                                    style: const TextStyle(fontSize: 10))),
                          ],
                        )),
                        spacer24,
                        GestureDetector(
                          onLongPress: _copy,
                          child: QrDisplay(
                              data: lightningUri, displayText: invoice ?? ""),
                        ),
                      ],
                    ),
                  ),
                ),
                spacer24,
                Row(
                  children: [
                    Expanded(
                      child: OutlineGradientButton(
                        text: "Share",
                        onTap: () => Share.share(invoice ?? ""),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                        child:
                            OutlineGradientButton(text: "Copy", onTap: _copy)),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
