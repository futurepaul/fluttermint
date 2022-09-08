import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import '../client.dart';

@immutable
class Balance {
  const Balance({required this.amountSats});

  final int amountSats;

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Balance copyWith({int? amountSats}) {
    return Balance(
      amountSats: amountSats ?? this.amountSats,
    );
  }
}

class BalanceNotifier extends StateNotifier<Balance?> {
  BalanceNotifier() : super(null);

  createBalance() async {
    try {
      final int balance = await api.balance();
      state = Balance(amountSats: balance);
    } catch (e) {
      debugPrint('Caught error in createBalance: $e');
      state = const Balance(amountSats: 0);
    }
  }

  clear() {
    state = null;
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, Balance?>((ref) {
  return BalanceNotifier();
});
