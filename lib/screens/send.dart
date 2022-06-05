import 'dart:math';

import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

class Send extends StatelessWidget {
  const Send({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onDetect(Barcode barcode, MobileScannerArguments? arguments) async {
      final data = barcode.rawValue;
      if (data != null) {
        debugPrint('Barcode found! $data');
        // TODO use rust to figure out if it's a valid bolt11
        context.go("/send/confirm");
      }
    }

    return Textured(
      child: Scaffold(
          appBar: FediAppBar(
            title: "Send bitcoin",
            closeAction: () => context.go("/"),
          ),
          backgroundColor: Colors.transparent,
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: MobileScanner(
                        allowDuplicates: false,
                        onDetect: onDetect,
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                OutlineGradientButton(
                    text: "Continue", onTap: () => context.go("/send/confirm"))
              ],
            ),
          )),
    );
  }
}

class InvertedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final side = min(size.width, size.height);
    final xOffset = (size.width - side) / 2;
    final yOffset = (size.height - side) / 2;

    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(xOffset, yOffset, side, side))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
