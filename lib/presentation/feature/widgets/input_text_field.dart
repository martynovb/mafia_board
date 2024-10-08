import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType textInputType;
  final List<TextInputFormatter> inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final String preText;
  final double? height;

  InputTextField({
    Key? key,
    required this.controller,
    this.height,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.maxLength,
    this.maxLines,
    this.inputFormatters = const [],
    this.preText = '',
  }) : super(key: key) {
    if (preText.isNotEmpty) {
      controller.text = preText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      height: height ?? Dimensions.inputTextHeight,
      child: TextField(
        keyboardType: textInputType,
        obscureText: obscureText,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        style: const TextStyle(fontSize: 14),
        maxLength: maxLength,
        maxLines: maxLines ?? 1,
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
    ));
  }
}
