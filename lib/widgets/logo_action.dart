import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/ffi.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';

class FedimintLogoAction extends ConsumerWidget {
  const FedimintLogoAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => {context.go("/about")},
      onLongPress: () => {
        showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: const Text('Leave Federation?'),
            content: const Text(
                'Are you sure you want to leave this federation? All your e-cash will be lost!'),
            actions: <Widget>[
              PlatformDialogAction(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text("Cancel")),
              PlatformDialogAction(
                  onPressed: () async {
                    context.go("/setup");
                    await api.leaveFederation();
                  },
                  child: const Text("Ok")),
            ],
          ),
        )
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Fluttermint",
              style: TextStyle(
                  fontFamily: "Archivo 125",
                  fontSize: 18,
                  color: white,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }
}
