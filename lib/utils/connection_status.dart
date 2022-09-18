import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermint/bridge_generated.dart';
import 'package:fluttermint/client.dart';

final connectionStreamProvider =
    StreamProvider.autoDispose<ConnectionStatus?>((ref) {
  Stream<ConnectionStatus?> connectionStatus() async* {
    var shouldPoll = true;
    while (shouldPoll) {
      try {
        await Future.delayed(const Duration(seconds: 5));
        final status = await api.connectionStatus();
        // TODO: maybe there's a better place to put this
        debugPrint(status.toString());
        yield status;
      } catch (e) {
        yield null;
      }
    }
  }

  return connectionStatus();
});
