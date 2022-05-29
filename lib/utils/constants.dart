import 'dart:ui';
import 'package:flutter/material.dart';

const COLOR_BLACK = Color(0xFF212121);
const COLOR_GREY = Color(0x7FFFFFFF);
const COLOR_OFF_WHITE = Color(0xFFA0A0A0);
const COLOR_WHITE = Color(0xFFF1F1F1);

Map<int, Color> color = {
  50: Color.fromRGBO(241, 241, 241, .1),
  100: Color.fromRGBO(241, 241, 241, .2),
  200: Color.fromRGBO(241, 241, 241, .3),
  300: Color.fromRGBO(241, 241, 241, .4),
  400: Color.fromRGBO(241, 241, 241, .5),
  500: Color.fromRGBO(241, 241, 241, .6),
  600: Color.fromRGBO(241, 241, 241, .7),
  700: Color.fromRGBO(241, 241, 241, .8),
  800: Color.fromRGBO(241, 241, 241, .9),
  900: Color.fromRGBO(241, 241, 241, 1),
};

MaterialColor white = MaterialColor(0xFFF1F1F1, color);

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
      fontFamily: "Archivo",
      color: COLOR_WHITE,
      fontSize: 18,
      fontVariations: [FontVariation("wght", 400.0)]),
  // Body 2 in the Figma
  headline4: TextStyle(
      color: COLOR_WHITE,
      fontSize: 16,
      fontVariations: [FontVariation("wght", 600.0)]),
  // Smaller balance display
  headline5: TextStyle(
      fontFamily: "Archivo",
      color: COLOR_WHITE,
      fontSize: 28,
      fontVariations: [
        FontVariation("wdth", 120.0),
        FontVariation("wght", 400.0)
      ]),
  // Unit for smaller balance display
  headline6: TextStyle(
      fontFamily: "Archivo",
      color: COLOR_WHITE,
      fontSize: 18,
      fontVariations: [
        FontVariation("wdth", 120.0),
        FontVariation("wght", 500.0)
      ]),
  bodyText1: TextStyle(color: COLOR_WHITE, fontSize: 14, height: 1.5),
  bodyText2: TextStyle(
      fontFamily: "Archivo",
      color: const Color(0xCCF1F1F1),
      fontSize: 14,
      fontVariations: [FontVariation("wght", 400.0)]),
  subtitle1: TextStyle(color: COLOR_WHITE, fontSize: 12),
  subtitle2: TextStyle(color: COLOR_GREY, fontSize: 12),
  caption: TextStyle(fontFamily: "Archivo", color: COLOR_BLACK, fontSize: 12),
);
