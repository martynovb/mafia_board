import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/auth/create_account_page.dart';
import 'package:mafia_board/presentation/feature/auth/login_page.dart';
import 'package:mafia_board/presentation/feature/auth/reset_password_page.dart';
import 'package:mafia_board/presentation/feature/home/home_page.dart';
import 'package:mafia_board/presentation/feature/settings/settings_page.dart';

class AppRouter {
  static const homePage = '/home';
  static const mePage = '/me';
  static const settingsPage = '/settings';
  static const loginPage = '/login';
  static const createAccountPage = '/createAccount';
  static const resetPasswordPage = '/resetPassword';

  static final Map<String, WidgetBuilder> routes = {
    homePage: (context) => const HomePage(),
    settingsPage: (context) => const SettingsPage(),
    loginPage: (context) => const LoginPage(),
    createAccountPage: (context) => const CreateAccountPage(),
    resetPasswordPage: (context) => const ResetPasswordPage(),
  };
}
