import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermint/screens/receive.dart';
import 'package:fluttermint/screens/receiveconfirm.dart';
import 'package:fluttermint/screens/send.dart';
import 'package:fluttermint/screens/sendconfirm.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: COLOR_BLACK,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Design 1',
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: COLOR_WHITE,
            textTheme: TEXT_THEME_DEFAULT,
            backgroundColor: COLOR_WHITE,
            scaffoldBackgroundColor: COLOR_BLACK,
            fontFamily: "Archivo"),
        initialRoute: "/",
        routes: {
          "/": (context) => const Home(),
          // "/pegin": (context) => const PegIn(),
          // "/pegout": (context) => PegOut(),
          "/send": (context) => const Send(),
          "/send/confirm": (context) => const SendConfirm(),
          "/receive": (context) => const Receive(),
          "/receive/confirm": (context) => const ReceiveConfirm()
          // "/receive": (context) => Receive(),
        });
  }
}
