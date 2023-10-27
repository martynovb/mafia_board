import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;

  const InputTextField({
    Key? key,
    required this.controller,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        obscureText: obscureText,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
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
