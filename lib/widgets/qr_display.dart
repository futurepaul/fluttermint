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
            QrImage(
                data: data,
                version: QrVersions.auto,
                // Screen width minus 40.0 for container and 48.0 for app padding
                // limit to 300 px
                size:
                    (MediaQuery.of(context).size.width - 88.0).clamp(0, 300.0)),
            spacer12,
            EllipsableText(
                text: displayText, style: Theme.of(context).textTheme.caption),
          ],
        ),
      ),
    );
  }
}
