import 'package:flutter/material.dart';

Future<String?> unimplementedDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Unimplemented'),
      content: const Text("This doesn't work yet"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
