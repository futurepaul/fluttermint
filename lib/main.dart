import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/router.dart';
import 'package:fluttermint/utils/constants.dart';
import './client.dart';

final isConnectedToFederation = StateProvider<bool>((ref) => false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final success = await api.init();

    debugPrint("init was = $success");
  } catch (e) {
    debugPrint('Caught error in init: $e');
  }

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  static const title = 'Fluttermint';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: white,
          primarySwatch: materialWhite,
          textTheme: textThemeDefault,
          backgroundColor: white,
          scaffoldBackgroundColor: black,
          fontFamily: "Inter"),
    );
  }
}
