import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';

import '../widgets/contentpadding.dart';
import '../widgets/fediappbar.dart';
import '../widgets/textured.dart';

class Receive extends StatelessWidget {
  const Receive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Receive",
            closeAction: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlineGradientButton(
                    text: "Continue",
                    onTap: () =>
                        Navigator.pushNamed(context, "/receive/confirm"))
              ],
            ),
          )),
    ));
  }
}
