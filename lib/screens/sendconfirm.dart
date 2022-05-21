import 'package:fluttermint/utils/unimplemented.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';

import '../widgets/contentpadding.dart';
import '../widgets/fediappbar.dart';
import '../widgets/textured.dart';

class SendConfirm extends StatelessWidget {
  const SendConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Confirm",
            closeAction: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            backAction: () {
              Navigator.popUntil(context, ModalRoute.withName('/send'));
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlineGradientButton(
                    text: "Confirm & Send",
                    onTap: () => unimplementedDialog(context))
              ],
            ),
          )),
    ));
  }
}
