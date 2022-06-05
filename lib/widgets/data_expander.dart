import 'dart:math';

import 'package:flutter/material.dart';

class DataExpander extends StatefulWidget {
  const DataExpander({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<DataExpander> createState() => _DataExpanderState();
}

class _DataExpanderState extends State<DataExpander> {
  bool _first = true;

  void _toggle() {
    setState(() => _first = !_first);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      sizeCurve: Curves.easeInOutQuad,
      firstChild: InkWell(
        onTap: () => _toggle(),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Icon(
                Icons.expand_more,
                color: Theme.of(context).primaryColor,
                size: 24.0,
                semanticLabel: 'Expand',
              ),
            ],
          ),
        ),
      ),
      secondChild: Column(
        children: [
          widget.child,
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _toggle(),
            child: SizedBox(
              width: double.infinity,
              child: Transform.rotate(
                angle: pi,
                child: Icon(
                  Icons.expand_more,
                  color: Theme.of(context).primaryColor,
                  size: 24.0,
                  semanticLabel: 'Minimize',
                ),
              ),
            ),
          )
        ],
      ),
      crossFadeState:
          _first ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 200),
    );
  }
}
