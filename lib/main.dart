import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermint/screens/receive.dart';
import 'package:fluttermint/screens/receive_confirm.dart';
import 'package:fluttermint/screens/send.dart';
import 'package:fluttermint/screens/send_confirm.dart';
import 'package:fluttermint/screens/send_finish.dart';
import 'package:fluttermint/screens/setup.dart';
import 'package:fluttermint/screens/setup_join.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/screens/home.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Initial Location';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: COLOR_WHITE,
          textTheme: TEXT_THEME_DEFAULT,
          backgroundColor: COLOR_WHITE,
          scaffoldBackgroundColor: COLOR_BLACK,
          fontFamily: "Archivo"),
    );
  }

  final _router = GoRouter(
    initialLocation: "/setup",
    routes: [
      GoRoute(
          path: "/setup",
          builder: (context, state) => const Setup(),
          routes: [
            GoRoute(
              path: 'join',
              builder: (context, state) => const SetupJoin(),
            ),
          ]),
      GoRoute(path: '/', builder: (context, state) => const Home(), routes: [
        GoRoute(
            path: 'send',
            builder: (context, state) => const Send(),
            routes: [
              GoRoute(
                path: 'confirm',
                builder: (context, state) => const SendConfirm(),
              ),
              GoRoute(
                path: 'finish',
                builder: (context, state) => const SendFinish(),
              ),
            ]),
        GoRoute(
            path: 'receive',
            builder: (context, state) => const Receive(),
            routes: [
              GoRoute(
                path: 'confirm',
                builder: (context, state) => const ReceiveConfirm(),
              ),
            ]),
      ]),
    ],
  );
}
