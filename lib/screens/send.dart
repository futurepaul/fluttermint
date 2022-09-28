import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/send.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

import '../ffi.dart';
import '../widgets/autopaste_text_field.dart';

class SendScreen extends ConsumerWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceController = TextEditingController();
    final sendNotifier = ref.read(sendProvider.notifier);
    // final theSend = ref.watch(sendProvider);

    Future<void> tryDecode(String data) async {
      try {
        debugPrint("decoding: $data");
        if (data.startsWith("lightning:")) {
          data = data.split(":")[1];
        }
        var decoded = await api.decodeInvoice(bolt11: data.toLowerCase());
        debugPrint("after decoded");
        debugPrint("amount: ${decoded.amount}");
        var send = Send(
            description: decoded.description,
            amountSats: decoded.amount,
            invoice: data);

        debugPrint("Decoded was not null");
        await sendNotifier.createSend(send).then((_) {
          context.go("/send/confirm");
        });
      } catch (err) {
        context.go("/errormodal", extra: err);
      }
    }

    // TODO: wire this up so we can do pastes nicer
    Future<void> checkIfWeCanSend() async {
      if (invoiceController.text.isNotEmpty) {
        final invoice = invoiceController.text;
        debugPrint('Invoice found! $invoice');
        await tryDecode(invoice.trim());
      }
    }

    Future<void> doTheSend() async {
      context.go("/send/confirm");
    }

    void onDetect(Barcode barcode, MobileScannerArguments? args) async {
      final data = barcode.rawValue;
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
                // QR scanner doesn't work on other platforms
                if (Platform.isAndroid || Platform.isIOS) ...[
                  Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: MobileScanner(
                            allowDuplicates: false, onDetect: onDetect)),
                  )
                ],
                const SizedBox(
                  height: 16,
                ),
                AutoPasteTextField(
                  labelText: "Paste Lightning Invoice",
                  controller: invoiceController,
                  initialValue: "",
                ),
                const SizedBox(
                  height: 16,
                ),
                OutlineGradientButton(
                    primary: true,
                    // disabled: theSend == null,
                    text: "Continue",
                    onTap: () async {
                      final maybeInvoice = invoiceController.value.text;
                      await tryDecode(maybeInvoice.trim());
                      // context.go("/send/confirm");
                    })
              ],
            ),
          )),
    );
  }
}
