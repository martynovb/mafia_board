import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/auth/create_account_page.dart';
import 'package:mafia_board/presentation/feature/auth/login_page.dart';
import 'package:mafia_board/presentation/feature/auth/reset_password_page.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_page.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_page.dart';
import 'package:mafia_board/presentation/feature/game/game_page.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/game/rules/rules_page.dart';
import 'package:mafia_board/presentation/feature/game/table/table_page.dart';
import 'package:mafia_board/presentation/feature/settings/settings_page.dart';

class AppRouter {
  static const gamePage = '/game';
  static const mePage = '/me';
  static const settingsPage = '/settings';
  static const loginPage = '/login';
  static const createAccountPage = '/createAccount';
  static const resetPasswordPage = '/resetPassword';
  static const playersSheetPage = '/playersSheet';
  static const tablePage = '/table';
  static const clubsPage = '/clubs';
  static const clubDetailsPage = '/clubDetails';
  static const gameRulesPage = '/gameRules';

  static final Map<String, WidgetBuilder> routes = {
    gamePage: (context) => const GamePage(),
    settingsPage: (context) => const SettingsPage(),
    loginPage: (context) => const LoginPage(),
    createAccountPage: (context) => const CreateAccountPage(),
    resetPasswordPage: (context) => const ResetPasswordPage(),
    playersSheetPage: (context) => const PlayersSheetPage(),
    tablePage: (context) => const TablePage(),
    clubsPage: (context) => const ClubsPage(),
    clubDetailsPage: (context) => const ClubDetailsPage(),
    gameRulesPage: (context) => const RulesPage(),
  };
}
