import 'package:flutter/material.dart';
import 'package:fluttermint/data/transactions.dart';
import 'package:fluttermint/utils/constants.dart';

class SingleTx extends StatelessWidget {
  const SingleTx({Key? key, required this.tx}) : super(key: key);

  final Transaction tx;

  String fmtSats(int sats) {
    return '$sats sats';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: tx.status == "Pending" ? 0.6 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: disabledGrey))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(tx.status), Text(fmtSats(tx.amountSats))],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      tx.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  spacer12,
                  Text(tx.when)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
