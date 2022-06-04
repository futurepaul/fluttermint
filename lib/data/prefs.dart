import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: constant_identifier_names
const String FEDERATION_CODE_KEY = "FEDERATION_CODE_KEY";

class FluttermintStateNotifier extends StateNotifier<String?> {
  FluttermintStateNotifier(this.prefs)
      : super(prefs.get(FEDERATION_CODE_KEY) as String?);

//  String _federationCode;
  SharedPreferences prefs;

  /// Updates the value asynchronously.
  Future<void> update(String? value) async {
    if (value != null) {
      await prefs.setString(FEDERATION_CODE_KEY, value);
    } else {
      await prefs.remove(FEDERATION_CODE_KEY);
    }
    super.state = value;
  }

  /// Do not use the setter for state.
  /// Instead, use `await update(value).`
  @override
  set state(String? value) {
    assert(false,
        "Don't use the setter for state. Instead use `await update(value)`.");
    Future(() async {
      await update(value);
    });
  }
}

StateNotifierProvider<FluttermintStateNotifier, String?> createPrefProvider({
  required SharedPreferences Function(Ref) prefs,
}) {
  return StateNotifierProvider<FluttermintStateNotifier, String?>(
      (ref) => FluttermintStateNotifier(prefs(ref)));
}
