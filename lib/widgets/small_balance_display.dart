import 'package:flutter/material.dart';

class SmallBalanceDisplay extends StatelessWidget {
  final int amountSats;

  const SmallBalanceDisplay({
    Key? key,
    required this.amountSats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(amountSats.toString(),
            style: Theme.of(context).textTheme.headline5),
        const SizedBox(width: 4),
        Text("SATS", style: Theme.of(context).textTheme.headline6),
      ],
    );
  }
}
