import 'package:fluttermint/utils/unimplemented.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:rounded_qr/rounded_qr.dart';

import '../widgets/contentpadding.dart';
import '../widgets/fediappbar.dart';
import '../widgets/textured.dart';

class ReceiveConfirm extends StatelessWidget {
  const ReceiveConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Receive bitcoin",
            backAction: () {
              Navigator.popUntil(context, ModalRoute.withName('/receive'));
            },
            closeAction: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RoundedQR(
                  data: 'https://flutter.dev',
                  moduleRadius: 0.0,
                  backgroundRadius: 0.0,
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
    ));
  }
}
