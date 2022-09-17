import 'package:flutter/material.dart';
import 'package:fluttermint/data/transactions.dart';
import 'package:fluttermint/utils/constants.dart';

class SingleTx extends StatelessWidget {
  SingleTx({Key? key, required this.tx}) : super(key: key);

  final Transaction tx;

  String fmtSats(int sats) {
    return '$sats sats';
  }

  final small =
      TextStyle(color: white.withOpacity(0.7), fontSize: 12, height: 1.5);
  final med = const TextStyle(color: white, fontSize: 15, height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: tx.status == "Pending" || tx.status == "Expired" ? 0.6 : 1.0,
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
                children: [
                  Text(tx.status, style: med),
                  Text(fmtSats(tx.amountSats), style: med)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      style: small,
                      tx.description.isEmpty
                          ? "No description"
                          : tx.description,
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
