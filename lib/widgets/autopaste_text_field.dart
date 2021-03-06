import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermint/utils/constants.dart';

class AutoPasteTextField extends StatelessWidget {
  const AutoPasteTextField(
      {Key? key,
      this.initialValue,
      required this.controller,
      required this.labelText})
      : super(key: key);

  final String labelText;
  final String? initialValue;
  final TextEditingController controller;

  void _clearText() {
    controller.clear();
  }

  void _setTextFromClipboard() {
    Clipboard.getData(Clipboard.kTextPlain).then((value) {
      if (value != null) {
        controller.text = "${value.text?.trim()}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.text = initialValue ?? "";
    return Column(
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              _setTextFromClipboard();
            }
          },
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
                labelText: labelText,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(width: 1, color: white)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(width: 1, color: white)),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearText,
                      )
                    : null),
          ),
        ),
      ],
    );
  }
}
