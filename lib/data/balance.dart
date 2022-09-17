import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import '../client.dart';

enum Denom { sats, btc }

extension ParseToString on Denom {
  String toReadableString() {
    switch (this) {
      case Denom.sats:
        return "SATS";
      case Denom.btc:
        return "BTC";
    }
  }
}

@immutable
class Balance {
  const Balance({required this.amountSats, this.denomination = Denom.sats});

  final int amountSats;
  final Denom denomination;

  //TODO: this could be a lot better
  String prettyPrint() {
    switch (denomination) {
      case Denom.sats:
        return amountSats.toString();
      case Denom.btc:
        return (amountSats / 100000000).toString();
    }
  }

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Balance copyWith({int? amountSats, Denom? denomination}) {
    return Balance(
      amountSats: amountSats ?? this.amountSats,
      denomination: denomination ?? this.denomination,
    );
  }
}

class BalanceNotifier extends StateNotifier<Balance?> {
  BalanceNotifier() : super(null);

  refreshBalance() async {
    try {
      final int balance = await api.balance();
      state =
          state?.copyWith(amountSats: balance) ?? Balance(amountSats: balance);
    } catch (e) {
      debugPrint('Caught error in refreshBalance: $e');
      state = null;
    }
  }

  switchDenom() async {
    debugPrint("switching denom");
    debugPrint("existing: ${state?.denomination.toString()}");
    var denom = state?.denomination;
    if (denom == Denom.sats) {
      denom = Denom.btc;
    } else {
      denom = Denom.sats;
    }
    debugPrint("new: $denom");

    state = state?.copyWith(denomination: denom);
  }

  clear() {
    state = null;
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, Balance?>((ref) {
  return BalanceNotifier();
});
