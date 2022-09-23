import 'package:flutter/material.dart';

const black = Color(0xFF212121);
const grey = Color.fromRGBO(255, 255, 255, 0.498);
const disabledGrey = Color(0xFFC4C4C4);
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

const spacer12 = SizedBox(
  height: 12.0,
  width: 12.0,
);
const spacer24 = SizedBox(height: 24.0, width: 12.0);
const spacer6 = SizedBox(height: 6.0, width: 6.0);
const spacer0 = SizedBox.shrink();

const TextTheme textThemeDefault = TextTheme(
  headline1: TextStyle(
    fontFamily: "Archivo 125",
    color: white,
    fontSize: 64,
    fontWeight: FontWeight.w500,
  ),
  headline2: TextStyle(
    fontFamily: "Archivo 125",
    color: white,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  ),
  headline3: TextStyle(
      fontFamily: "Archivo",
      color: white,
      fontSize: 18,
      fontWeight: FontWeight.w400),
  // Body 2 in the Figma
  headline4: TextStyle(
      fontFamily: "Archivo",
      color: white,
      fontSize: 16,
      fontWeight: FontWeight.w600),
  // Smaller balance display
  headline5: TextStyle(
      fontFamily: "Archivo 125",
      color: white,
      fontSize: 28,
      fontWeight: FontWeight.w400),
  // Unit for smaller balance display
  headline6: TextStyle(
    fontFamily: "Archivo 125",
    color: white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  ),
  bodyText1: TextStyle(color: white, fontSize: 14, height: 1.5),
  bodyText2: TextStyle(
      color: Color(0xCCF1F1F1), fontSize: 14, fontWeight: FontWeight.w400),
  subtitle1: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
  subtitle2: TextStyle(color: grey, fontSize: 12),
  caption: TextStyle(fontFamily: "Archivo 125", color: black, fontSize: 12),
);
