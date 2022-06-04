import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/main.dart';
import 'package:fluttermint/widgets/autopaste_text_field.dart';
import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

class SetupJoin extends ConsumerStatefulWidget {
  const SetupJoin({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SetupJoinState();
}

class _SetupJoinState extends ConsumerState<SetupJoin> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {}

  @override
  Widget build(BuildContext context) {
    final codeProvider = ref.read(prefProvider);
    final textController = TextEditingController();

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
                AutoPasteTextField(
                  controller: textController,
                  initialValue: codeProvider ?? "",
                ),
                const SizedBox(height: 16),
                OutlineGradientButton(
                    text: "Continue",
                    onTap: () async {
                      var newText = textController.text;

                      await ref.read(prefProvider.notifier).update(newText);

                      // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
                      if (!mounted) return;
                      context.go("/");
                    })
              ],
            ),
          )),
    );
  }
}
