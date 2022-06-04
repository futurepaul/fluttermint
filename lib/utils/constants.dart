import 'dart:ui';
import 'package:flutter/material.dart';

const black = Color(0xFF212121);
const grey = Color(0x7FFFFFFF);
const offwhite = Color(0xFFA0A0A0);
const white = Color(0xFFF1F1F1);

Map<int, Color> color = {
  50: const Color.fromRGBO(241, 241, 241, .1),
  100: const Color.fromRGBO(241, 241, 241, .2),
  200: const Color.fromRGBO(241, 241, 241, .3),
  300: const Color.fromRGBO(241, 241, 241, .4),
  400: const Color.fromRGBO(241, 241, 241, .5),
  500: const Color.fromRGBO(241, 241, 241, .6),
  600: const Color.fromRGBO(241, 241, 241, .7),
  700: const Color.fromRGBO(241, 241, 241, .8),
  800: const Color.fromRGBO(241, 241, 241, .9),
  900: const Color.fromRGBO(241, 241, 241, 1),
};

MaterialColor materialWhite = MaterialColor(0xFFF1F1F1, color);

const TextTheme textThemeDefault = TextTheme(
  headline1: TextStyle(
      fontFamily: "Archivo",
      color: white,
      fontSize: 64,
      fontVariations: [
        FontVariation("wdth", 120.0),
        FontVariation("wght", 500.0)
      ]),
  headline2: TextStyle(
      fontFamily: "Archivo",
      color: white,
      fontSize: 22,
      fontVariations: [
        FontVariation("wdth", 120.0),
        FontVariation("wght", 500.0)
      ]),
  headline3: TextStyle(
      fontFamily: "Archivo",
      color: white,
      fontSize: 18,
      fontVariations: [FontVariation("wght", 400.0)]),
  // Body 2 in the Figma
  headline4: TextStyle(
      color: white,
      fontSize: 16,
      fontVariations: [FontVariation("wght", 600.0)]),
  // Smaller balance display
  headline5: TextStyle(
      fontFamily: "Archivo",
      color: white,
      fontSize: 28,
      fontVariations: [
        FontVariation("wdth", 120.0),
        FontVariation("wght", 400.0)
      ]),
  // Unit for smaller balance display
  headline6: TextStyle(
      fontFamily: "Archivo",
      color: white,
      fontSize: 18,
      fontVariations: [
        FontVariation("wdth", 120.0),
        FontVariation("wght", 500.0)
      ]),
  bodyText1: TextStyle(color: white, fontSize: 14, height: 1.5),
  bodyText2: TextStyle(
      fontFamily: "Archivo",
      color: Color(0xCCF1F1F1),
      fontSize: 14,
      fontVariations: [FontVariation("wght", 400.0)]),
  subtitle1: TextStyle(color: white, fontSize: 12),
  subtitle2: TextStyle(color: grey, fontSize: 12),
  caption: TextStyle(fontFamily: "Archivo", color: black, fontSize: 12),
);
