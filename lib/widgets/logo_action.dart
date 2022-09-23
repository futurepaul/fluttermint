import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../client.dart';
import '../utils/constants.dart';

class FedimintLogoAction extends ConsumerWidget {
  const FedimintLogoAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => {context.go("/about")},
      onLongPress: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Leave Federation?'),
          content: const Text(
              'Are you sure you want to leave this federation? All your e-cash will be lost!'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                context.go("/setup");
                await api.leaveFederation();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "Fluttermint",
            style: TextStyle(
                fontFamily: "Archivo 125",
                fontSize: 18,
                color: white,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
