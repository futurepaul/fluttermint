import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:fluttermint/widgets/outline_gradient.dart';

import '../utils/constants.dart';

class OutlineGradientButton extends StatelessWidget {
  final String text;
  final bool disabled;
  final double strokeWidth;
  final Radius radius;
  final Gradient gradient;
  final GestureTapCallback onTap;
  final GestureLongPressCallback? onLongPress;
  final String? tooltip;
  final bool primary;

  const OutlineGradientButton(
      {Key? key,
      required this.text,
      this.strokeWidth = 2.0,
      this.gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xfff1f1f1), Color(0xffA0A0A0)]),
      this.radius = const Radius.circular(30),
      this.disabled = false,
      required this.onTap,
      this.onLongPress,
      this.tooltip,
      this.primary = false})
      : assert(strokeWidth > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = BorderRadius.all(radius);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: disabled
                ? Colors.white.withOpacity(0.03)
                : Colors.white.withOpacity(0.1),
            blurRadius: 30.0,
            spreadRadius: 0.0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: br,
        child: InkWell(
          splashColor:
              primary ? black.withOpacity(0.1) : white.withOpacity(0.1),
          borderRadius: br,
          onTap: disabled ? null : onTap,
          onLongPress: onLongPress,
          child: CustomPaint(
            painter: primary
                ? null
                : OutlinePainter(
                    LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: disabled
                            ? [
                                white.withOpacity(0.3),
                                offwhite.withOpacity(0.3)
                              ]
                            : [white, offwhite]),
                    radius,
                    strokeWidth),
            child: Ink(
                decoration: BoxDecoration(
                    borderRadius: br,
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: primary
                            ? const [Color(0xfff4f4f3), Color(0xffc8c8c7)]
                            : [
                                const Color(0xffffffff).withOpacity(0.2),
                                const Color(0xffA0A0A0).withOpacity(0.0)
                              ]),
                    boxShadow: primary
                        ? [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.75),
                                offset: const Offset(0.0, -1.0),
                                blurRadius: 3.0,
                                inset: true),
                            BoxShadow(
                                color: Colors.white.withOpacity(0.25),
                                offset: const Offset(0.0, 1.0),
                                blurRadius: 3.0,
                                inset: true)
                          ]
                        : null),
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Text(text,
                        style: TextStyle(
                            fontFamily: "Archivo",
                            color: primary
                                ? black
                                : disabled
                                    ? white.withOpacity(0.3)
                                    : white,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                blurRadius: primary ? 1.0 : 0.0,
                                color: primary
                                    ? white
                                    : disabled
                                        ? black.withOpacity(0.3)
                                        : black,
                                offset: Offset(0.0, primary ? -1.0 : 1.0),
                              ),
                            ],
                            fontWeight: FontWeight.w600)),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
