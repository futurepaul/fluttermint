import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/screens/home.dart';
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

final isConnectedToFederation = StateProvider<bool>((ref) => false);

class SetupJoin extends ConsumerWidget {
  const SetupJoin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    // Trying this so we don't do context.go across async boundary
    ref.listen<bool>(isConnectedToFederation, (_, isConnected) {
      debugPrint(isConnected.toString());
      if (isConnected) {
        // When we connect to another federation we need to refresh which network
        context.go("/");
      }
    });

    void joinFederation(String cfg) async {
      try {
        ref.read(isConnectedToFederation.notifier).state = false;
        await api.joinFederation(configUrl: cfg);
        ref.read(isConnectedToFederation.notifier).state = true;
        ref.refresh(bitcoinNetworkProvider);
        debugPrint("Joined federation from setup screen");
      } catch (e) {
        debugPrint('Caught error in joinFederation: $e');
        ref.read(isConnectedToFederation.notifier).state = false;
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
                // QR scanner doesn't work on other platforms
                if (Platform.isAndroid || Platform.isIOS) ...[
                  Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: QRViewExample(onDetect: onDetect)),
                  )
                ],
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
                        joinFederation(newText);
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
