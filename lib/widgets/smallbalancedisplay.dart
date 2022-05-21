import 'package:flutter/material.dart';

class SmallBalanceDisplay extends StatelessWidget {
  const SmallBalanceDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("615,000", style: Theme.of(context).textTheme.headline5),
        const SizedBox(width: 4),
        Text("SATS", style: Theme.of(context).textTheme.headline6),
      ],
    );
  }
}
