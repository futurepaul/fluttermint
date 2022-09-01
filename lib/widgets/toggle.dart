import 'package:flutter/material.dart';
import 'dart:math';

class Toggle extends StatelessWidget {
  const Toggle({Key? key, required this.onToggle, required this.active})
      : super(key: key);

  final VoidCallback onToggle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            active
                ? Transform.rotate(
                    angle: pi,
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).primaryColor,
                      size: 24.0,
                      semanticLabel: 'Minimize',
                    ),
                  )
                : Icon(
                    Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                    size: 24.0,
                    semanticLabel: 'Expand',
                  ),
          ],
        ),
      ),
    );
  }
}
