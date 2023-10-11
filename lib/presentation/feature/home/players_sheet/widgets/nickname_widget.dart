import 'dart:async';
import 'package:flutter/material.dart';

class NicknameWidget extends StatelessWidget {
  final TextEditingController _textController;
  Timer? _timer;
  bool enabled;

  NicknameWidget({
    super.key,
    String? nickname,
    required Function(String nickname) onChanged,
    required this.enabled,
  }) : _textController = TextEditingController() {
    _textController.value = _textController.value.copyWith(
      text: nickname,
      selection: TextSelection.collapsed(offset: nickname?.length ?? 0),
    );

    _textController.addListener(() {
      if (_timer != null) {
        _timer?.cancel();
      }

      _timer = Timer(const Duration(seconds: 1), () {
        onChanged(_textController.value.text);
      });
    });

    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: nickname?.length ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 1,
      enabled: enabled,
      controller: _textController,
      decoration: const InputDecoration(
        hintText: 'nickname',
        border: InputBorder.none,
      ),
    );
  }
}
