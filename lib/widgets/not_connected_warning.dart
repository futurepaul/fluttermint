import 'package:flutter/material.dart';
import 'package:fluttermint/bridge_generated.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/utils/network_detector_notifier.dart';
import 'package:fluttermint/widgets/chill_info_card.dart';

class NotConnectedWarning extends StatelessWidget {
  const NotConnectedWarning(
      {super.key, this.connectionStatus, this.networkStatus});

  final ConnectionStatus? connectionStatus;
  final NetworkStatus? networkStatus;

  @override
  Widget build(BuildContext context) {
    final message = networkStatus == NetworkStatus.Off
        ? "No Internet Connection Detected"
        : connectionStatus == ConnectionStatus.NotConnected
            ? "Couldn't Connect To Federation"
            : null;

    return message != null
        ? Column(
            children: [
              ChillInfoCard(
                warning: true,
                child: Column(
                  children: [
                    Text("Warning",
                        style: Theme.of(context).textTheme.headline6),
                    spacer12,
                    Text(message, style: Theme.of(context).textTheme.subtitle1),
                  ],
                ),
              ),
              spacer24
            ],
          )
        : const SizedBox(
            height: 0,
          );
  }
}
