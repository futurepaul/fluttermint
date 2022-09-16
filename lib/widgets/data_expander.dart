import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/toggle.dart';

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
      firstChild: Toggle(
        active: false,
        onToggle: _toggle,
      ),
      secondChild: Column(
        children: [
          widget.child,
          const SizedBox(height: 16),
          Toggle(onToggle: _toggle, active: true)
        ],
      ),
      crossFadeState:
          _first ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 200),
    );
  }
}
