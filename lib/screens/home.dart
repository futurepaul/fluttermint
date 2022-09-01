import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/fedi_tooltip.dart';

import 'package:fluttermint/widgets/textured.dart';
import 'package:fluttermint/widgets/transaction_list.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/balance_display.dart';
import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/logo_action.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BalanceDisplay(),
                spacer24,
                const TransactionsList(),
                spacer24,
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: FediTooltip(
                          title: "heyo",
                          child: OutlineGradientButton(
                              text: "Receive",
                              onTap: () {
                                context.go("/receive");
                              }),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: OutlineGradientButton(
                            text: "Send",
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
