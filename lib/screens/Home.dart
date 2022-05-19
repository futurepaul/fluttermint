import 'dart:ui';

import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/testbutton.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: COLOR_BLACK,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));

    return SafeArea(
        child: Scaffold(
            body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TestButton(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text("fluttermint",
                  style: TextStyle(
                      fontSize: 18,
                      color: COLOR_WHITE,
                      fontVariations: [
                        FontVariation("wdth", 112.0),
                        FontVariation("wght", 600.0)
                      ])),
              Icon(
                Icons.expand_more,
                color: COLOR_GREY,
                size: 24.0,
              ),
            ],
          ),
          Column(
            children: const [
              Text("32,615",
                  style: TextStyle(
                      fontFamily: "Archivo",
                      color: COLOR_WHITE,
                      fontSize: 64,
                      fontVariations: [
                        FontVariation("wdth", 120.0),
                        FontVariation("wght", 500.0)
                      ])),
              Text("SATS",
                  style: TextStyle(
                      fontFamily: "Archivo",
                      color: COLOR_WHITE,
                      fontSize: 22,
                      fontVariations: [
                        FontVariation("wdth", 120.0),
                        FontVariation("wght", 500.0)
                      ])),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xfff1f1f1), Color(0xffA0A0A0)]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 30.0,
                        spreadRadius: 0.0,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff4C4C4C), Color(0xff242424)]),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Text("Receive",
                            style: TextStyle(color: COLOR_WHITE)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xfff1f1f1), Color(0xffA0A0A0)]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 30.0,
                        spreadRadius: 0.0,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff4C4C4C), Color(0xff242424)]),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child:
                            Text("Send", style: TextStyle(color: COLOR_WHITE)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    )));
  }
}
