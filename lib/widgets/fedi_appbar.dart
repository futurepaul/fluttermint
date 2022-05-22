import 'package:flutter/material.dart';

class FediAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final void Function()? backAction;
  final void Function()? closeAction;

  const FediAppBar({
    Key? key,
    required this.title,
    this.backAction,
    this.closeAction,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          backAction != null
              ? InkWell(
                  onTap: backAction,
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                    size: 24.0,
                    semanticLabel: 'Back',
                  ))
              : const SizedBox(
                  width: 24,
                ),
          Text(title, style: Theme.of(context).textTheme.headline3),
          InkWell(
            onTap: closeAction,
            child: Icon(
              Icons.close,
              color: Theme.of(context).primaryColor,
              size: 24.0,
              semanticLabel: 'Close',
            ),
          ),
        ],
      ),
    );
  }
}
