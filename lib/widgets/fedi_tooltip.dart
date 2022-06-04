import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttermint/utils/constants.dart';

class FediTooltip extends StatelessWidget {
  const FediTooltip({Key? key, required this.child, required this.title})
      : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

    return Tooltip(
      // Provide a global key with the "TooltipState" type to show
      // the tooltip manually when trigger mode is set to manual.
      // key: tooltipkey.currentState?.ensureTooltipVisible(),
      triggerMode: TooltipTriggerMode.manual,
      key: key,
      showDuration: const Duration(seconds: 1),
      waitDuration: const Duration(seconds: 1),
      message: 'I am a Tooltip?',
      padding: const EdgeInsets.all(14.0),
      textStyle: const TextStyle(
          fontSize: 14.0,
          color: black,
          fontVariations: [FontVariation("wght", 500)]),
      preferBelow: false,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              blurRadius: 4.0,
              offset: const Offset(0.0, 4.0),
              color: Colors.black.withOpacity(0.3))
        ],
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[white, Color(0xffc3c3c3)]),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: child,
      ),
    );
  }
}
