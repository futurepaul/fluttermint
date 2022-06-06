import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/receive.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final receiveNotifier = ref.read(receiveProvider.notifier);

    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Receive",
            closeAction: () {
              receiveNotifier.clear();
              context.go("/");
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    TextField(
                      controller: amountController,
                      autofocus: true,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: "Archivo 125",
                          fontSize: 52,
                          fontWeight: FontWeight.w400),
                    ),
                    Text("SATS", style: Theme.of(context).textTheme.headline6),
                    const SizedBox(
                      height: 36,
                    ),
                    TextField(
                      controller: descriptionController,
                      style: Theme.of(context).textTheme.subtitle1,
                      decoration: InputDecoration(
                        labelText: "Description",
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(width: 1, color: white)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(width: 1, color: white)),
                      ),
                    ),
                  ],
                ),
                OutlineGradientButton(
                    primary: true,
                    text: "Continue",
                    onTap: () async {
                      var desc = descriptionController.text;
                      var amount = int.parse(amountController.text);
                      try {
                        await receiveNotifier.createReceive(
                            Receive(description: desc, amountSats: amount));
                        // TODO figure out the right way to do this async without the mounted flag
                        context.go("/receive/confirm");
                      } catch (err) {
                        print("observed error $err");
                        context.go("/errormodal", extra: err);
                      }
                    })
              ],
            ),
          )),
    );
  }
}
