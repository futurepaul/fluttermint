import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/utils/unimplemented.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/chill_info_card.dart';
import 'package:fluttermint/widgets/small_balance_display.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

import 'package:qr_flutter/qr_flutter.dart';

import 'package:fluttermint/widgets/ellipsable_text.dart';

class ReceiveConfirm extends StatelessWidget {
  const ReceiveConfirm({Key? key}) : super(key: key);

  static const lightningInvoice =
      "lnbc20m1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqhp58yjmdan79s6qqdhdzgynm4zwqd5d7xmw5fk98klysy043l2ahrqsfpp3qjmp7lwpagxun9pygexvgpjdc4jdj85fr9yq20q82gphp2nflc7jtzrcazrra7wwgzxqc8u7754cdlpfrmccae92qgzqvzq2ps8pqqqqqqpqqqqq9qqqvpeuqafqxu92d8lr6fvg0r5gv0heeeqgcrqlnm6jhphu9y00rrhy4grqszsvpcgpy9qqqqqqgqqqqq7qqzqj9n4evl6mr5aj9f58zp6fyjzup6ywn3x6sk8akg5v4tgn2q8g4fhx05wf6juaxu9760yp46454gpg5mtzgerlzezqcqvjnhjh8z3g2qqdhhwkjo";

  final lightningUri = "lightning$lightningInvoice";

  @override
  Widget build(BuildContext context) {
    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Receive bitcoin",
            backAction: () {
              context.go("/receive");
              // context.back();
            },
            closeAction: () {
              context.go("/");
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
                        child:
                            Image(image: AssetImage("images/bolt-circle.png"))),
                    const SizedBox(height: 8),
                    Text("RECEIVE",
                        style: Theme.of(context).textTheme.headline4),
                    const SizedBox(height: 16),
                    const SmallBalanceDisplay(),
                    const SizedBox(height: 8),
                    Text("Pineapple pizza slice",
                        style: Theme.of(context).textTheme.bodyText2)
                  ],
                )),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        QrImage(
                            data: lightningUri,
                            version: QrVersions.auto,
                            // Screen width minus 40.0 for container and 48.0 for app padding
                            size: MediaQuery.of(context).size.width - 88.0),
                        const SizedBox(height: 16),
                        EllipsableText(
                            text: lightningInvoice,
                            style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlineGradientButton(
                        text: "Share",
                        onTap: () => unimplementedDialog(context),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: OutlineGradientButton(
                        text: "Copy",
                        onTap: () => unimplementedDialog(context),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
