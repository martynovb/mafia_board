import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/presentation/feature/mafia_board_app.dart';

void main() {
  setupGetIt();
  runApp(const MafiaBoardApp());
}

void setupGetIt() {
  GetIt.I.registerLazySingleton(() => BoardRepository());
  GetIt.I.registerLazySingleton(() => RoleManager.classic(GetIt.I.get()));
  GetIt.I.registerLazySingleton(() => PlayerValidator());
}
