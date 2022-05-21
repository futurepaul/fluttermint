import 'dart:ui';

import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/contentpadding.dart';
import '../widgets/fediappbar.dart';
import '../widgets/textured.dart';

class Setup extends StatelessWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                const SizedBox(
                    width: 295,
                    height: 295,
                    child: Image(image: AssetImage("images/fed-graphic.png"))),
                const SizedBox(height: 32),
                const Text("Fedimint\nis a private\nlightning wallet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Archivo",
                        fontSize: 40,
                        // 3% of 40
                        letterSpacing: -1.2,
                        color: COLOR_WHITE,
                        fontVariations: [
                          FontVariation("wght", 600),
                          FontVariation("wdth", 120)
                        ])),
                const Spacer(),
                OutlineGradientButton(
                    text: "Get Started", onTap: () => context.go("/setup/join"))
              ],
            ),
          )),
    );
  }
}
