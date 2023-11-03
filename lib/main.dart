import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mafia_board/data/api/token_provider.dart';
import 'package:mafia_board/presentation/feature/mafia_board_app.dart';
import 'package:mafia_board/presentation/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await TokenProvider().openBox();
  Injector.inject(true);
  runApp(const MafiaBoardApp());
}
