import 'package:flutter/cupertino.dart';

class MafLogger {
  static const _appName = 'MAFIA-BOARD';
  static void d(String tag, String message) {
    debugPrint('$_appName/$tag/D: $message');
  }

  static void e(String tag, String message) {
    debugPrint('$_appName/$tag/E: $message');
  }
}
