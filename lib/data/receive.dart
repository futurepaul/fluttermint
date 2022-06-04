import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class Receive {
  const Receive(
      {required this.id,
      required this.description,
      required this.amountSats,
      this.invoice});

  final String id;
  final String description;
  final int amountSats;
  final String? invoice;

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Receive copyWith(
      {String? id, String? description, int? amountSats, String? invoice}) {
    return Receive(
      id: id ?? this.id,
      description: description ?? this.description,
      amountSats: amountSats ?? this.amountSats,
      invoice: invoice ?? this.invoice,
    );
  }
}

class ReceiveNotifier extends StateNotifier<Receive?> {
  ReceiveNotifier() : super(null);

  createReceive(Receive receive) async {
    // TODO RUST GOES HERE
    await Future.delayed(const Duration(seconds: 1));
    const invoice =
        "lnbc20m1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqhp58yjmdan79s6qqdhdzgynm4zwqd5d7xmw5fk98klysy043l2ahrqsfpp3qjmp7lwpagxun9pygexvgpjdc4jdj85fr9yq20q82gphp2nflc7jtzrcazrra7wwgzxqc8u7754cdlpfrmccae92qgzqvzq2ps8pqqqqqqpqqqqq9qqqvpeuqafqxu92d8lr6fvg0r5gv0heeeqgcrqlnm6jhphu9y00rrhy4grqszsvpcgpy9qqqqqqgqqqqq7qqzqj9n4evl6mr5aj9f58zp6fyjzup6ywn3x6sk8akg5v4tgn2q8g4fhx05wf6juaxu9760yp46454gpg5mtzgerlzezqcqvjnhjh8z3g2qqdhhwkjo";
    state = receive.copyWith(invoice: invoice);
  }

  clear() {
    state = null;
  }
}

final receiveProvider = StateNotifierProvider<ReceiveNotifier, Receive?>((ref) {
  return ReceiveNotifier();
});
