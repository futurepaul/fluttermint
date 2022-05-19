import 'package:flutter/material.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/screens/Home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Design 1',
      theme: ThemeData(
          primaryColor: COLOR_WHITE,
          textTheme: TEXT_THEME_DEFAULT,
          backgroundColor: COLOR_BLACK,
          scaffoldBackgroundColor: COLOR_BLACK,
          fontFamily: "Archivo"),
      home: Home(),
    );
  }
}
