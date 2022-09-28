import 'package:fluttermint/screens/home.dart';
import 'package:fluttermint/utils/constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final isCreatingReceive = StateProvider<bool>((ref) => false);

const repo = 'https://github.com/futurepaul/fluttermint';
const faucet = 'https://faucet.sirion.io/';

final packageInfoProvider = FutureProvider<PackageInfo>((_) async {
  return await PackageInfo.fromPlatform();
});

class AboutScreen extends HookConsumerWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoOnce = ref.watch(packageInfoProvider);
    final bitcionNetwork = ref.watch(bitcoinNetworkProvider);
    return Textured(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: FediAppBar(
          title: "About",
          closeAction: () {
            context.go("/");
          },
        ),
        body: ContentPadding(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NETWORK", style: Theme.of(context).textTheme.headline6),
                  spacer6,
                  bitcionNetwork.when(
                      data: (data) => Text(data),
                      error: (err, stacktrace) => Text(err.toString()),
                      loading: () => spacer0),
                  spacer24,
                  Text("VERSION", style: Theme.of(context).textTheme.headline6),
                  spacer6,
                  packageInfoOnce.when(
                      data: (data) =>
                          Text("${data.version} + ${data.buildNumber}"),
                      error: (err, stacktrace) => Text(err.toString()),
                      loading: () => spacer0),
                  spacer24,
                  Text("CONTRIBUTE",
                      style: Theme.of(context).textTheme.headline6),
                  spacer6,
                  GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(repo);
                        if (!await launchUrl(url)) {
                          throw 'Could not launch $url';
                        }
                      },
                      child: const Text(repo,
                          style:
                              TextStyle(decoration: TextDecoration.underline))),
                  spacer24,
                  Text("SIGNET FAUCET",
                      style: Theme.of(context).textTheme.headline6),
                  spacer6,
                  GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(faucet);
                        if (!await launchUrl(url)) {
                          throw 'Could not launch $url';
                        }
                      },
                      child: const Text(faucet,
                          style:
                              TextStyle(decoration: TextDecoration.underline)))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
