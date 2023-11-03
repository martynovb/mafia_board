import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/auth/create_account_page.dart';
import 'package:mafia_board/presentation/feature/auth/login_page.dart';
import 'package:mafia_board/presentation/feature/auth/reset_password_page.dart';
import 'package:mafia_board/presentation/feature/home/board/board_page.dart';
import 'package:mafia_board/presentation/feature/home/home_page.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/settings/settings_page.dart';
import 'package:mafia_board/presentation/feature/table/table_page.dart';

class AppRouter {
  static const gamePage = '/game';
  static const mePage = '/me';
  static const settingsPage = '/settings';
  static const loginPage = '/login';
  static const createAccountPage = '/createAccount';
  static const resetPasswordPage = '/resetPassword';
  static const playersSheetPage = '/playersSheet';
  static const boardPage = '/boardPage';
  static const tablePage = '/tablePage';

  static final Map<String, WidgetBuilder> routes = {
    gamePage: (context) => const GamePage(),
    settingsPage: (context) => const SettingsPage(),
    loginPage: (context) => const LoginPage(),
    createAccountPage: (context) => const CreateAccountPage(),
    resetPasswordPage: (context) => const ResetPasswordPage(),
    playersSheetPage: (context) => const PlayersSheetPage(),
    boardPage: (context) => const BoardPage(),
    tablePage: (context) => const TablePage(),
  };
}
