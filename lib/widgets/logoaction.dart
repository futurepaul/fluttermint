import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class FedimintLogoAction extends StatelessWidget {
  const FedimintLogoAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text("Fedimint",
            style: TextStyle(fontSize: 18, color: COLOR_WHITE, fontVariations: [
              FontVariation("wdth", 112.0),
              FontVariation("wght", 600.0)
            ])),
        Icon(
          Icons.expand_more,
          color: COLOR_GREY,
          size: 24.0,
        ),
      ],
    );
  }
}
