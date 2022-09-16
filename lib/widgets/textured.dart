import 'package:flutter/material.dart';

class Textured extends StatelessWidget {
  final Widget child;

  const Textured({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/app/bg-dark.png"), fit: BoxFit.cover)),
      child: SafeArea(child: child),
    );
  }
}
