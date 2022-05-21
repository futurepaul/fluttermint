import 'package:fluttermint/utils/unimplemented.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/contentpadding.dart';
import '../widgets/fediappbar.dart';
import '../widgets/textured.dart';

class SendConfirm extends StatelessWidget {
  const SendConfirm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Confirm",
            closeAction: () {
              // context.go("/");
              context.pop();
              context.pop();
            },
            backAction: () {
              // context.go("/send");
              context.pop();
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
    );
  }
}
