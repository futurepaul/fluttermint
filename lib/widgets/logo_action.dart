import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';

class FedimintLogoAction extends ConsumerWidget {
  const FedimintLogoAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        context.go("/setup");
      },
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
