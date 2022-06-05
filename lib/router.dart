import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/data/receive.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// SCREENS
import 'package:fluttermint/screens/receive.dart';
import 'package:fluttermint/screens/receive_confirm.dart';
import 'package:fluttermint/screens/send.dart';
import 'package:fluttermint/screens/send_confirm.dart';
import 'package:fluttermint/screens/send_finish.dart';
import 'package:fluttermint/screens/setup.dart';
import 'package:fluttermint/screens/setup_join.dart';
import 'package:fluttermint/screens/home.dart';

import 'main.dart';
// import 'user.dart';

/// Caches and Exposes a [GoRouter]
final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: true, // For demo purposes
    refreshListenable: router, // This notifiies `GoRouter` for refresh events
    redirect: router._redirectLogic, // All the logic is centralized here
    routes: router._routes, // All the routes can be found there
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  /// This implementation exploits `ref.listen()` to add a simple callback that
  /// calls `notifyListeners()` whenever there's change onto a desider provider.
  RouterNotifier(this._ref) {
    _ref.listen<String?>(
      prefProvider,
      (_, __) => notifyListeners(),
    );

    _ref.listen<Receive?>(
      receiveProvider,
      (_, __) => notifyListeners(),
    );
  }

  /// IMPORTANT: conceptually, we want to use `ref.read` to read providers, here.
  /// GoRouter is already aware of state changes through `refreshListenable`
  /// We don't want to trigger a rebuild of the surrounding provider.
  String? _redirectLogic(GoRouterState state) {
    final federationCode = _ref.read(prefProvider);
    final receive = _ref.read(receiveProvider);

    final areWeInSetup =
        state.location == '/setup' || state.location == '/setup/join';

    if (federationCode == null) {
      return areWeInSetup ? null : '/setup';
    }

    // // Receive has been populated
    // if (state.location == '/receive' && receive != null) {
    //   return '/receive/confirm';
    // }

    // // Receive was cancelled
    // if (state.location == '/receive/confirm' && receive == null) {
    //   return '/';
    // }

    return null;
  }

  List<GoRoute> get _routes => [
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
              builder: (context, state) => const SendScreen(),
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
              builder: (context, state) => const ReceiveScreen(),
              routes: [
                GoRoute(
                  path: 'confirm',
                  builder: (context, state) => const ReceiveConfirm(),
                ),
              ]),
        ]),
      ];
}
