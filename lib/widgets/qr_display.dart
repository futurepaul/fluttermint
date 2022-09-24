import 'package:flutter/material.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/ellipsable_text.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplay extends StatelessWidget {
  const QrDisplay({
    Key? key,
    required this.data,
    required this.displayText,
  }) : super(key: key);

  final String data;
  final String displayText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // debugPrint(constraints.toString());
            Container(
              constraints: BoxConstraints(
                  maxHeight: (MediaQuery.of(context).size.height / 2)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: QrImage(
                    data: data,
                    version: QrVersions.auto,
                  ),
                ),
              ),
            ),
            EllipsableText(
                text: displayText, style: Theme.of(context).textTheme.caption),
          ],
        ),
      ),
    );
  }
}
