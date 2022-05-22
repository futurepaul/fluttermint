import 'dart:math';

import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/ellipsable_text.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

import '../widgets/chill_info_card.dart';
import '../widgets/small_balance_display.dart';

class SendConfirm extends StatefulWidget {
  const SendConfirm({Key? key}) : super(key: key);

  @override
  State<SendConfirm> createState() => _SendConfirmState();
}

class _SendConfirmState extends State<SendConfirm> {
  bool _first = true;

  static const lightningInvoice =
      "lnbc20m1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqhp58yjmdan79s6qqdhdzgynm4zwqd5d7xmw5fk98klysy043l2ahrqsfpp3qjmp7lwpagxun9pygexvgpjdc4jdj85fr9yq20q82gphp2nflc7jtzrcazrra7wwgzxqc8u7754cdlpfrmccae92qgzqvzq2ps8pqqqqqqpqqqqq9qqqvpeuqafqxu92d8lr6fvg0r5gv0heeeqgcrqlnm6jhphu9y00rrhy4grqszsvpcgpy9qqqqqqgqqqqq7qqzqj9n4evl6mr5aj9f58zp6fyjzup6ywn3x6sk8akg5v4tgn2q8g4fhx05wf6juaxu9760yp46454gpg5mtzgerlzezqcqvjnhjh8z3g2qqdhhwkjo";

  void _toggle() {
    setState(() => _first = !_first);
  }

  @override
  Widget build(BuildContext context) {
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
                        child:
                            Image(image: AssetImage("images/bolt-circle.png"))),
                    const SizedBox(height: 8),
                    Text("SEND", style: Theme.of(context).textTheme.headline4),
                    const SizedBox(height: 16),
                    const SmallBalanceDisplay(),
                    const SizedBox(height: 8),
                    Text("Pineapple pizza slice",
                        style: Theme.of(context).textTheme.bodyText2),
                    const SizedBox(height: 16),
                    AnimatedCrossFade(
                      sizeCurve: Curves.easeInOutQuad,
                      firstChild: InkWell(
                        onTap: () => _toggle(),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Icon(
                                Icons.expand_more,
                                color: Theme.of(context).primaryColor,
                                size: 24.0,
                                semanticLabel: 'Expand',
                              ),
                            ],
                          ),
                        ),
                      ),
                      secondChild: Column(children: [
                        Divider(
                          thickness: 1,
                          indent:
                              ((MediaQuery.of(context).size.width - 80) / 2.0) -
                                  12.0,
                          endIndent:
                              ((MediaQuery.of(context).size.width - 80) / 2.0) -
                                  12.0,
                          color: COLOR_WHITE,
                        ),
                        const SizedBox(height: 16),
                        const Text("Fee is ~3 – 11 sats"),
                        const SizedBox(height: 8),
                        const Text("Expires in 1440 min"),
                        const SizedBox(height: 8),
                        const EllipsableText(
                            text: lightningInvoice, style: null),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _toggle(),
                          child: SizedBox(
                            width: double.infinity,
                            child: Transform.rotate(
                              angle: pi,
                              child: Icon(
                                Icons.expand_more,
                                color: Theme.of(context).primaryColor,
                                size: 24.0,
                                semanticLabel: 'Minimize',
                              ),
                            ),
                          ),
                        )
                      ]),
                      crossFadeState: _first
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 200),
                    )
                  ],
                )),
                OutlineGradientButton(
                    text: "Send 615,000 SATS",
                    onTap: () => context.go("/send/finish"))
              ],
            ),
          )),
    );
  }
}
