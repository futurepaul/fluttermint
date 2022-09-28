import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/ffi.dart';
import 'package:fluttermint/screens/about.dart';
import 'package:fluttermint/screens/error_page.dart';
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

CustomTransitionPage buildPageWithDefaultTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

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
  // TODO: the dream is we listen here for configured / connection status and can re-route accordingly
  RouterNotifier(this._ref) {
    // _ref.listen<bool?>(
    //   configuredProvider,
    //   (_, __) => notifyListeners(),
    // );
  }

  /// IMPORTANT: conceptually, we want to use `ref.read` to read providers, here.
  /// GoRouter is already aware of state changes through `refreshListenable`
  /// We don't want to trigger a rebuild of the surrounding provider.
  FutureOr<String?> _redirectLogic(
      BuildContext context, GoRouterState state) async {
    final configured = await api.configuredStatus();

    final areWeInSetup =
        state.location == '/setup' || state.location == '/setup/join';

    final areWeInError = state.location == "/errormodal";
    debugPrint(areWeInError.toString());

    if (!configured && !areWeInSetup && !areWeInError) {
      debugPrint("redirecting to setup");
      return "/setup";
    }

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
          GoRoute(
              path: "errormodal",
              pageBuilder: (context, state) {
                return MaterialPage(
                    fullscreenDialog: true,
                    child: ErrorPage(
                        errorReason: state.extra is ErrorWhy
                            ? state.extra as ErrorWhy
                            : ErrorWhy(reason: state.extra.toString())));
              }),
          GoRoute(
            path: "about",
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AboutScreen(),
            ),
          )
        ]),
      ];
}
