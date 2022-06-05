import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

@immutable
class Send {
  const Send(
      {required this.description, required this.amountSats, this.invoice});

  final String description;
  final int amountSats;
  final String? invoice;

  // Since Receive is immutable, we implement a method that allows cloning the
  // Receive with slightly different content.
  Send copyWith({String? description, int? amountSats, String? invoice}) {
    return Send(
      description: description ?? this.description,
      amountSats: amountSats ?? this.amountSats,
      invoice: invoice ?? this.invoice,
    );
  }
}

class SendNotifier extends StateNotifier<Send?> {
  SendNotifier() : super(null);

  createSend(Send send) async {
    // TODO RUST GOES HERE
    await Future.delayed(const Duration(seconds: 1));
    const invoice =
        "lnbc20m1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqhp58yjmdan79s6qqdhdzgynm4zwqd5d7xmw5fk98klysy043l2ahrqsfpp3qjmp7lwpagxun9pygexvgpjdc4jdj85fr9yq20q82gphp2nflc7jtzrcazrra7wwgzxqc8u7754cdlpfrmccae92qgzqvzq2ps8pqqqqqqpqqqqq9qqqvpeuqafqxu92d8lr6fvg0r5gv0heeeqgcrqlnm6jhphu9y00rrhy4grqszsvpcgpy9qqqqqqgqqqqq7qqzqj9n4evl6mr5aj9f58zp6fyjzup6ywn3x6sk8akg5v4tgn2q8g4fhx05wf6juaxu9760yp46454gpg5mtzgerlzezqcqvjnhjh8z3g2qqdhhwkjo";
    state = send.copyWith(invoice: invoice);
  }

  clear() {
    state = null;
  }
}

final sendProvider = StateNotifierProvider<SendNotifier, Send?>((ref) {
  return SendNotifier();
});
