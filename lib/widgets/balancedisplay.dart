import 'package:flutter/material.dart';

class BalanceDisplay extends StatelessWidget {
  const BalanceDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("32,615", style: Theme.of(context).textTheme.headline1),
        Text("SATS", style: Theme.of(context).textTheme.headline2),
      ],
    );
  }
}
