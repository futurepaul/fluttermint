import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:fluttermint/screens/error_page.dart';
import 'package:fluttermint/screens/home.dart';
import 'package:fluttermint/widgets/autopaste_text_field.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../ffi.dart';

final isConnectedToFederation = StateProvider<bool>((ref) => false);

class SetupJoin extends ConsumerWidget {
  const SetupJoin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    // This listener is so we don't context.go across async boundary
    ref.listen<bool>(isConnectedToFederation, (_, isConnected) {
      // When we connect to another federation we need to refresh which network
      ref.refresh(bitcoinNetworkProvider);
      if (isConnected) {
        api.network().then((value) async {
          debugPrint(value);
          // If we connect to a mainnet federation, warn about it
          if (value == "bitcoin") {
            await joinWarning(context, ref);
          } else {
            // Otherwise we're clear to go to home
            context.go("/");
          }
        });
      }
    });

    void joinFederation(String cfg) async {
      try {
        ref.read(isConnectedToFederation.notifier).state = false;
        await api.joinFederation(configUrl: cfg);
        ref.read(isConnectedToFederation.notifier).state = true;
      } on FfiException catch (e) {
        debugPrint('Caught error in joinFederation: $e');
        ref.read(isConnectedToFederation.notifier).state = false;
        debugPrint(e.message);
        context.go("/errormodal",
            extra: ErrorWhy(
                title: "Failed to join federation", reason: e.message));
      }
    }

    void onDetect(Barcode barcode, MobileScannerArguments? args) async {
      final data = barcode.rawValue;
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
                // QR scanner doesn't work on other platforms
                if (Platform.isAndroid || Platform.isIOS) ...[
                  Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: MobileScanner(
                            allowDuplicates: false, onDetect: onDetect)),
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
                      joinFederation(newText);
                    })
              ],
            ),
          )),
    );
  }

  joinWarning(BuildContext context, WidgetRef ref) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text(
            "You've just joined a mainnet federation. Fluttermint is in early alpha, and fund-loss is a real possibility. Please use with caution!"),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              context.go("/setup");
              await api.leaveFederation();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // This triggers to nav to "/"
              ref.read(isConnectedToFederation.notifier).state = true;
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
