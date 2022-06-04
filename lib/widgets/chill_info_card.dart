import 'package:flutter/material.dart';
import 'package:fluttermint/utils/constants.dart';

class ChillInfoCard extends StatelessWidget {
  final Widget child;
  const ChillInfoCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Add one stop for each color. Stops should increase from 0 to 1
            colors: [white.withOpacity(0.2), white.withOpacity(0.04)],
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(20), child: child));
  }
}
