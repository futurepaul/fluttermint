import 'dart:ui';

import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

class Receive extends StatelessWidget {
  const Receive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Receive",
            closeAction: () {
              context.go("/");
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const TextField(
                      autofocus: true,
                      decoration: InputDecoration(border: InputBorder.none),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 52, fontVariations: [
                        FontVariation("wght", 400),
                        FontVariation("wdth", 120)
                      ]),
                    ),
                    Text("SATS", style: Theme.of(context).textTheme.headline6),
                    const SizedBox(
                      height: 36,
                    ),
                    TextField(
                      style: const TextStyle(
                          fontSize: 16,
                          fontVariations: [FontVariation("wght", 400)]),
                      decoration: InputDecoration(
                        labelText: "Description",
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(width: 1, color: COLOR_WHITE)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(width: 1, color: COLOR_WHITE)),
                      ),
                    ),
                  ],
                ),
                OutlineGradientButton(
                    text: "Continue",
                    onTap: () => context.go("/receive/confirm"))
              ],
            ),
          )),
    );
  }
}
