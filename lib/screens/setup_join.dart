import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/main.dart';
import 'package:fluttermint/widgets/autopaste_text_field.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/qr_scanner.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../ffi.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

class SetupJoin extends ConsumerWidget {
  const SetupJoin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeProvider = ref.read(prefProvider);
    final codeProviderNotifier = ref.read(prefProvider.notifier);
    final textController = TextEditingController();

    void joinFederation(String cfg) async {
      await api.joinFederation(
          configUrl: cfg,
          userDir: await getApplicationDocumentsDirectory()
              .then((dir) => dir.toString()));
      await codeProviderNotifier.update(cfg);
      context.go("/");
    }

    void onDetect(Barcode barcode) async {
      final data = barcode.code;
      if (data != null) {
        debugPrint('Barcode found! $data');
        joinFederation(data);
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
                  initialValue: codeProvider ?? "",
                ),
                const SizedBox(height: 16),
                OutlineGradientButton(
                    text: "Continue",
                    onTap: () async {
                      var newText = textController.text;

                      // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
                      // TODO: error if this isn't valid
                      joinFederation(newText);
                    })
              ],
            ),
          )),
    );
  }
}
