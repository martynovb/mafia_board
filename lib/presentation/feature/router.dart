import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/auth/create_account_page.dart';
import 'package:mafia_board/presentation/feature/auth/login_page.dart';
import 'package:mafia_board/presentation/feature/auth/reset_password_page.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_page.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_page.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/create_club_page.dart';
import 'package:mafia_board/presentation/feature/game/game_details/game_details_page.dart';
import 'package:mafia_board/presentation/feature/game/game_page.dart';
import 'package:mafia_board/presentation/feature/game/game_result/game_results_page.dart';
import 'package:mafia_board/presentation/feature/game/rules/rules_page.dart';
import 'package:mafia_board/presentation/feature/home/home_page.dart';
import 'package:mafia_board/presentation/feature/settings/settings_page.dart';

class AppRouter {
  static const gamePage = '/game';
  static const mePage = '/me';
  static const settingsPage = '/settings';
  static const loginPage = '/login';
  static const createAccountPage = '/createAccount';
  static const resetPasswordPage = '/resetPassword';
  static const tablePage = '/table';
  static const clubsPage = '/clubs';
  static const clubDetailsPage = '/clubDetails';
  static const gameRulesPage = '/gameRules';
  static const gameResultsPage = '/gameResults';
  static const createClubPage = '/createClub';
  static const homePage = '/home';
  static const gameDetailsPage = '/gameDetails';

  static final Map<String, WidgetBuilder> routes = {
    gamePage: (context) => const GamePage(),
    settingsPage: (context) => const SettingsPage(),
    loginPage: (context) => const LoginPage(),
    createAccountPage: (context) => const CreateAccountPage(),
    resetPasswordPage: (context) => const ResetPasswordPage(),
    clubsPage: (context) => const ClubsPage(),
    clubDetailsPage: (context) => const ClubDetailsPage(),
    gameRulesPage: (context) => const RulesPage(),
    gameResultsPage: (context) => const GameResultsPage(),
    createClubPage: (context) => const CreateClubPage(),
    homePage: (context) => const HomePage(),
    gameDetailsPage: (context) => const GameDetailsPage(),
  };
}
