import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/balance.dart';
import 'package:fluttermint/data/send.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/data_expander.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

import '../widgets/chill_info_card.dart';
import '../widgets/small_balance_display.dart';

final isSending = StateProvider<bool>((ref) => false);

class SendConfirm extends ConsumerWidget {
  const SendConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = ref.read(sendProvider)!;
    final sendNotifier = ref.read(sendProvider.notifier);
    final sending = ref.watch(isSending);
    final sendingNotifier = ref.read(isSending.notifier);

    final invoice = send.invoice;
    // final lightningUri = "lightning:$invoice";
    final desc = send.description;
    final amount = send.amountSats;
    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Confirm send",
            closeAction: () {
              context.go("/");
            },
            backAction: () {
              context.pop();
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChillInfoCard(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                        width: 32,
                        height: 32,
                        child: Image(
                            image: AssetImage("assets/app/bolt-circle.png"))),
                    const SizedBox(height: 8),
                    Text("SEND", style: Theme.of(context).textTheme.headline4),
                    const SizedBox(height: 16),
                    SmallBalanceDisplay(
                      amountSats: send.amountSats,
                    ),
                    const SizedBox(height: 8),
                    Text(desc, style: Theme.of(context).textTheme.bodyText2),
                    const SizedBox(height: 16),
                    DataExpander(
                      child: Column(children: [
                        Divider(
                          thickness: 1,
                          indent:
                              ((MediaQuery.of(context).size.width - 80) / 2.0) -
                                  12.0,
                          endIndent:
                              ((MediaQuery.of(context).size.width - 80) / 2.0) -
                                  12.0,
                          color: white,
                        ),
                        const SizedBox(height: 8),
                        // EllipsabltextText(text: invoice, style: null),
                        Text(invoice)
                      ]),
                    )
                  ],
                )),
                OutlineGradientButton(
                    primary: true,
                    disabled: sending,
                    pending: sending,
                    text: "Send $amount SATS",
                    onTap: () async {
                      sendingNotifier.state = true;
                      try {
                        await sendNotifier.pay(send);
                        await ref
                            .read(balanceProvider.notifier)
                            .refreshBalance()
                            .then((_) async {
                          context.go("/");
                        });
                      } catch (err) {
                        context.go("/errormodal", extra: err);
                      } finally {
                        sendingNotifier.state = false;
                      }
                    })
              ],
            ),
          )),
    );
  }
}
