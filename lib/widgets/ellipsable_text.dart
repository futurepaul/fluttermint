import 'package:flutter/material.dart';

extension on String {
  List<String> splitByLength(int length) =>
      [substring(0, length), substring(length)];
}

class EllipsableText extends StatelessWidget {
  const EllipsableText({Key? key, required this.text, required this.style})
      : super(key: key);

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Text(text.splitByLength(text.length - 8)[0],
              maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
        Text(
          text.splitByLength(text.length - 8)[1],
          style: style,
        ),
      ],
    );
  }
}
