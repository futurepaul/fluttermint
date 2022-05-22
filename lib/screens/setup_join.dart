import 'package:flutter/services.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/autopaste_text_field.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

class SetupJoin extends StatelessWidget {
  SetupJoin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: const Image(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "images/dirtyqr.png",
                        )),
                  ),
                ),
                const SizedBox(height: 16),
                AutoPasteTextField(),
                const SizedBox(height: 16),
                OutlineGradientButton(
                    text: "Continue", onTap: () => context.go("/"))
              ],
            ),
          )),
    );
  }
}
