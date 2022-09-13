import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/send.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/qr_scanner.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../client.dart';
import '../widgets/autopaste_text_field.dart';

final isCreatingSend = StateProvider<bool>((ref) => false);

class SendScreen extends ConsumerWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    final sendNotifier = ref.read(sendProvider.notifier);
    final send = ref.watch(sendProvider);

    Future<void> tryDecode(String data) async {
      try {
        debugPrint("decoding: $data");
        var decoded = jsonDecode(await api.decodeInvoice(bolt11: data));
        debugPrint("after decoded");
        debugPrint("amount: ${decoded["amount"]}");
        var send = Send(
            description: decoded["description"],
            amountSats: (decoded["amount"] != null) ? decoded["amount"]! : 0,
            invoice: decoded["invoice"]);

        debugPrint("Decoded was not null");
        await sendNotifier.createSend(send).then((_) {
          context.go("/send/confirm");
        });
      } catch (err) {
        context.go("/errormodal", extra: err);
      }
    }

    // TODO is it right that I'm defining the function in here?
    void onDetect(Barcode barcode) async {
      final data = barcode.code;
      if (data != null) {
        debugPrint('Barcode found! $data');
        await tryDecode(data.trim());
      }
    }

    return Textured(
      child: Scaffold(
          appBar: FediAppBar(
            title: "Send bitcoin",
            closeAction: () => context.go("/"),
          ),
          backgroundColor: Colors.transparent,
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: QRViewExample(onDetect: onDetect)),
                ),
                const SizedBox(
                  height: 16,
                ),
                AutoPasteTextField(
                  labelText: "Paste Lightning Invoice",
                  controller: textController,
                  initialValue: "",
                ),
                const SizedBox(
                  height: 16,
                ),
                OutlineGradientButton(
                    disabled: textController.text == "",
                    text: "Continue",
                    onTap: () async {
                      final maybeInvoice = textController.text;
                      await tryDecode(maybeInvoice.trim());
                    })
              ],
            ),
          )),
    );
  }
}
