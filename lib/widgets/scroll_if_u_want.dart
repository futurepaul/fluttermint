import 'package:flutter/material.dart';

// This is basically SingleChildScrollView except it works the way I want it to
class ScrollIfYouWant extends StatelessWidget {
  const ScrollIfYouWant({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [SliverFillRemaining(child: child)]);
  }
}
