import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/mafia_board_app.dart';
import 'package:mafia_board/presentation/injector.dart';

void main() {
  Injector.inject();
  runApp(const MafiaBoardApp());
}
