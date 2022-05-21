import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttermint/widgets/outlinegradient.dart';

import '../utils/constants.dart';

class OutlineGradientButton extends StatelessWidget {
  final String text;
  final double strokeWidth;
  final Radius radius;
  final Gradient gradient;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double elevation;
  final bool inkWell;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final ValueChanged<bool>? onHighlightChanged;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;

  OutlineGradientButton({
    Key? key,
    required this.text,
    this.strokeWidth = 2.0,
    this.gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xfff1f1f1), Color(0xffA0A0A0)]),
    this.radius = const Radius.circular(30),
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.inkWell = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.onFocusChange,
  })  : assert(strokeWidth > 0),
        assert(padding.isNonNegative),
        assert(elevation >= 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = BorderRadius.all(radius);
    return Material(
      color: backgroundColor,
      elevation: elevation,
      borderRadius: br,
      child: InkWell(
        borderRadius: br,
        // highlightColor:
        //     inkWell ? Theme.of(context).highlightColor : Colors.transparent,
        // splashColor:
        //     inkWell ? Theme.of(context).splashColor : Colors.transparent,
        // highlightColor: Colors.transparent,
        // splashFactory: Intera,
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onHighlightChanged: onHighlightChanged,
        onHover: onHover,
        onFocusChange: onFocusChange,
        child: CustomPaint(
          painter: OutlinePainter(
              const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xfff1f1f1), Color(0xffA0A0A0)]),
              radius,
              strokeWidth),
          child: Ink(
              decoration: BoxDecoration(
                borderRadius: br,
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xffffffff).withOpacity(0.2),
                      const Color(0xffA0A0A0).withOpacity(0.0)
                    ]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 30.0,
                    spreadRadius: 0.0,
                  )
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Text(text,
                      style: const TextStyle(
                          color: COLOR_WHITE,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 0.0,
                              color: COLOR_BLACK,
                              offset: Offset(0.0, 1.0),
                            ),
                          ],
                          fontVariations: [
                            FontVariation("wght", 600)
                          ])),
                ),
              )),
        ),
      ),
    );
  }
}
