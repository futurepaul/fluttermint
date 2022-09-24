import 'package:flutter/material.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:intl/intl.dart';

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
        Text(NumberFormat.decimalPattern().format(amountSats),
            style: smallBalanceText),
        const SizedBox(width: 4),
        Text("SATS", style: smallBalanceText.copyWith(color: whiteFaded)),
      ],
    );
  }
}
