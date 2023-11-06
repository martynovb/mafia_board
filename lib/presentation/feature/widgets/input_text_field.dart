import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType textInputType;
  final List<TextInputFormatter> inputFormatters;
  final int? maxLength;

  const InputTextField({
    Key? key,
    required this.controller,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.maxLength,
    this.inputFormatters = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimensions.inputTextHeight,
      child: TextField(
        keyboardType: textInputType,
        obscureText: obscureText,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        style: const TextStyle(fontSize: 14),
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          counterText: '',
          contentPadding:
              const EdgeInsets.only(left: Dimensions.defaultSidePadding),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
