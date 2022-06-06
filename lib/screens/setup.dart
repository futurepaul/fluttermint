import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:rive/rive.dart';

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
                  child: RiveAnimation.asset("assets/spinny_globe.riv"),
                ),
                const SizedBox(height: 32),
                const Text("Fedimint\nis a private\nlightning wallet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Archivo 125",
                        fontSize: 38,
                        // 3% of 40
                        letterSpacing: -1.2,
                        color: white,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                OutlineGradientButton(
                    text: "Get Started", onTap: () => context.go("/setup/join"))
              ],
            ),
          )),
    );
  }
}
