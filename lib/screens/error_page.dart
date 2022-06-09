import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  final String errorReason;
  const ErrorPage({Key? key, required this.errorReason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Textured(
        child: Scaffold(
            appBar: FediAppBar(
              title: "ERROR",
              closeAction: () => context.go("/"),
            ),
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(errorReason)),
            )));
  }
}
