import 'package:fluttermint/utils/constants.dart';
import 'package:fluttermint/widgets/textured.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:fluttermint/widgets/content_padding.dart';
import 'package:fluttermint/widgets/fedi_appbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ffi.dart';

final isCreatingReceive = StateProvider<bool>((ref) => false);

const repo = 'https://github.com/futurepaul/fluttermint';
const faucet = 'https://faucet.sirion.io/';

final federationListProvider =
    FutureProvider<List<BridgeFederationInfo>>((_) async {
  return await api.listFederations();
});

final packageInfoProvider = FutureProvider<PackageInfo>((_) async {
  return await PackageInfo.fromPlatform();
});

class AboutScreen extends HookConsumerWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoOnce = ref.watch(packageInfoProvider);
    final federationList = ref.watch(federationListProvider);

    final feds = federationList.when(
        data: (data) => data,
        error: (error, stackTrace) => ([]),
        loading: () => ([]));

    final activeFed = federationList.when(
        data: (data) => data.firstWhere((fed) => fed.current == true),
        error: (error, stackTrace) {},
        loading: () {});

    final fedsNames = federationList.when(
        data: (data) => data.map((fed) => fed.name),
        error: (error, stackTrace) {},
        loading: () {});

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
                  Text("FEDERATION",
                      style: Theme.of(context).textTheme.headline6),
                  spacer6,
                  Text("${activeFed?.name} on ${activeFed?.network} network"),
                  DropdownButton<String>(
                    value: activeFed?.name,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (value) {
                      // This is called when the user selects an item.
                      // setState(() {
                      //   dropdownValue = value!;
                      // });
                    },
                    items: fedsNames?.map<DropdownMenuItem<String>>((fed) {
                      return DropdownMenuItem<String>(
                        value: fed,
                        child: Text(fed),
                      );
                    }).toList(),
                  ),
                  spacer24,
                  Text("GUARDIANS",
                      style: Theme.of(context).textTheme.headline6),
                  spacer6,
                  ...activeFed != null
                      ? activeFed.guardians.map(
                          (g) => GuardianItem(name: g.name, current: g.online),
                        )
                      : [const SizedBox.shrink()],
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

class GuardianItem extends StatelessWidget {
  const GuardianItem({
    Key? key,
    required this.name,
    required this.current,
  }) : super(key: key);

  final String name;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: current ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(6))),
            spacer12,
            Text(name, style: guardianText),
          ],
        ),
        spacer6,
      ],
    );
  }
}
