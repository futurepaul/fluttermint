import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/router.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import './ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final userDir = (await getApplicationDocumentsDirectory()).path;
    final success = await api.init(path: userDir);
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
      // IOS
      statusBarBrightness: Brightness.dark,
      // Android, opposite meaning lol
      statusBarIconBrightness: Brightness.light,
    ));

    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
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
          fontFamily: "Albert Sans"),
    );
  }
}
