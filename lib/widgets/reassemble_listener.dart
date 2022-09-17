import 'package:flutter/cupertino.dart';

class ReassembleListener extends StatefulWidget {
  const ReassembleListener(
      {Key? key, required this.onReassemble, required this.child})
      : super(key: key);

  final VoidCallback onReassemble;
  final Widget child;

  @override
  _ReassembleListenerState createState() => _ReassembleListenerState();
}

class _ReassembleListenerState extends State<ReassembleListener> {
  @override
  void reassemble() {
    super.reassemble();
    if (widget.onReassemble != null) {
      widget.onReassemble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
