import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermint/utils/constants.dart';

class AutoPasteTextField extends StatefulWidget {
  const AutoPasteTextField({Key? key}) : super(key: key);

  @override
  State<AutoPasteTextField> createState() => _AutoPasteTextFieldState();
}

class _AutoPasteTextFieldState extends State<AutoPasteTextField> {
  final TextEditingController _federationCodeField = TextEditingController();

  void _clearText() {
    _federationCodeField.clear();
  }

  void _setTextFromClipboard() {
    Clipboard.getData(Clipboard.kTextPlain).then((value) {
      _federationCodeField.text = "${value?.text?.trim()}";
    });
  }

  @override
  Widget build(BuildContext context) {
    _federationCodeField.addListener(() {
      setState(() {});
    });
    return Column(
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              _setTextFromClipboard();
            }
          },
          child: TextField(
            controller: _federationCodeField,
            decoration: InputDecoration(
                labelText: "Paste federation code",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(width: 1, color: COLOR_WHITE)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(width: 1, color: COLOR_WHITE)),
                suffixIcon: _federationCodeField.text.isNotEmpty
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
