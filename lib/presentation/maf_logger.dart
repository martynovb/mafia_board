import 'package:flutter/cupertino.dart';

class MafLogger {
  static void d(String tag, String message) {
    debugPrint('$tag/D: $message');
  }

  static void e(String tag, String message) {
    debugPrint('$tag/E: $message');
  }
}
