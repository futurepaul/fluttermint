import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/widgets/autopaste_text_field.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/qr_scanner.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../client.dart';

class SetupJoin extends ConsumerWidget {
  const SetupJoin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    void joinFederation(String cfg) async {
      try {
        await api.joinFederation(configUrl: cfg).then((_) => {context.go("/")});
      } catch (e) {
        debugPrint('Caught error in joinFederation: $e');
        context.go("/errormodal", extra: e);
      }
    }

    void onDetect(Barcode barcode) async {
      final data = barcode.code;
      if (data != null) {
        debugPrint('Barcode found! $data');
        try {
          joinFederation(data);
        } catch (e) {
          debugPrint('Caught error in onDetect: $e');
          context.go("/errormodal", extra: e);
        }
      }
    }

    return Textured(
      child: Scaffold(
          appBar: FediAppBar(
            title: "Join Federation",
            closeAction: () => context.go("/setup"),
          ),
          backgroundColor: Colors.transparent,
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    // TODO some sort of clip for aiming the scanner
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: QRViewExample(onDetect: onDetect))),
                const SizedBox(height: 16),
                AutoPasteTextField(
                  labelText: "Paste Federation Code",
                  controller: textController,
                  initialValue: "",
                ),
                const SizedBox(height: 16),
                OutlineGradientButton(
                    text: "Continue",
                    onTap: () async {
                      var newText = textController.text;
                      // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
                      try {
                        var test = joinFederation(newText);
                      } catch (err) {
                        context.go("/errormodal", extra: err);
                      }
                    })
              ],
            ),
          )),
    );
  }
}
