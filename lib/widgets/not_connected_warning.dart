import 'package:flutter/material.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/chill_info_card.dart';

class NotConnectedWarning extends StatelessWidget {
  const NotConnectedWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return ChillInfoCard(
      warning: true,
      child: Column(
        children: [
          Text("Warning", style: Theme.of(context).textTheme.headline6),
          spacer12,
          Text("No Internet Connection Detected",
              style: Theme.of(context).textTheme.subtitle1),
        ],
      ),
    );
  }
}
