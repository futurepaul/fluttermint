import 'package:fluttermint/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';

class SendFinish extends StatefulWidget {
  const SendFinish({Key? key}) : super(key: key);

  @override
  State<SendFinish> createState() => _SendFinishState();
}

class _SendFinishState extends State<SendFinish> {
  double scale = 1.0;

  void _changeScale() {
    setState(() => scale = scale == 1.0 ? 0.8 : 1.0);
  }

  @override
  initState() {
    super.initState();
    Future(() {
      _changeScale();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Textured(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: FediAppBar(
            title: "Sending...",
            closeAction: () {
              context.go("/");
            },
          ),
          body: ContentPadding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutQuad,
                  onEnd: () => _changeScale(),
                  child: const Image(
                    image: AssetImage("assets/app/polygon.png"),
                  ),
                ),
                OutlineGradientButton(
                    text: "Cancel", onTap: () => context.go("/"))
              ],
            ),
          )),
    );
  }
}
