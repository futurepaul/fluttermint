import 'package:flutter/material.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:go_router/go_router.dart';

class ErrorWhy {
  final String? title;
  final String reason;

  ErrorWhy({this.title, required this.reason});
}

class ErrorPage extends StatelessWidget {
  final ErrorWhy errorReason;
  const ErrorPage({Key? key, required this.errorReason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Textured(
        child: Scaffold(
            appBar: FediAppBar(
              title: "Error",
              closeAction: () => context.go("/"),
            ),
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Center(
                  child: Column(
                children: [
                  if (errorReason.title != null) ...[
                    Text(errorReason.title ?? "", style: errorTitleText),
                    spacer12,
                  ],
                  Text(errorReason.reason, style: errorDescriptionText),
                ],
              )),
            )));
  }
}
