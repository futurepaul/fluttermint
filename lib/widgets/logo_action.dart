import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../utils/constants.dart';

class FluttermintLogoAction extends ConsumerWidget {
  const FluttermintLogoAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        // Clear the federation code, which redirects us to setup
        await ref.read(prefProvider.notifier).update(null);
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
