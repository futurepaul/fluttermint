import 'dart:ui';
import 'package:flutter/material.dart';

const COLOR_BLACK = Color(0xFF212121);
const COLOR_GREY = Color(0x7FFFFFFF);
const COLOR_WHITE = Color(0xFFF1F1F1);
// const COLOR_PALE_SCREEN = Color.fromRGBO(255, 255, 255, 0.2);

// const GRADIENT_DARK = LinearGradient(
//   begin: Alignment.topCenter,
//   end: Alignment.bottomCenter,
//   colors: <Color>[
//     COLOR_BLACK.withOpacity(0.4), Colors.white.withOpacity(0.2)],
// );

const TextTheme TEXT_THEME_DEFAULT = TextTheme(
    headline1: TextStyle(
        fontFamily: "Archivo",
        color: COLOR_WHITE,
        fontSize: 64,
        fontVariations: [
          FontVariation("wdth", 120.0),
          FontVariation("wght", 500.0)
        ]),
    headline2: TextStyle(
        fontFamily: "Archivo",
        color: COLOR_WHITE,
        fontSize: 22,
        fontVariations: [
          FontVariation("wdth", 120.0),
          FontVariation("wght", 500.0)
        ]),
    headline3: TextStyle(
        color: COLOR_WHITE,
        fontSize: 18,
        fontVariations: [FontVariation("wght", 400.0)]),
    headline4: TextStyle(color: COLOR_WHITE, fontSize: 16),
    headline5: TextStyle(color: COLOR_WHITE, fontSize: 14),
    headline6: TextStyle(color: COLOR_WHITE, fontSize: 12),
    bodyText1: TextStyle(color: COLOR_WHITE, fontSize: 14, height: 1.5),
    bodyText2: TextStyle(color: COLOR_GREY, fontSize: 14, height: 1.5),
    subtitle1: TextStyle(color: COLOR_WHITE, fontSize: 12),
    subtitle2: TextStyle(color: COLOR_GREY, fontSize: 12));
