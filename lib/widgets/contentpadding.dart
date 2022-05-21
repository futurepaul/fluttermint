import 'package:flutter/material.dart';

class ContentPadding extends StatelessWidget {
  final Widget child;

  const ContentPadding({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
        child: child);
  }
}
