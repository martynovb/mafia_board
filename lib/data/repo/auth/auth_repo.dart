import 'package:mafia_board/data/model/user_model.dart';

abstract class AuthRepo {
  Future<UserModel> registerUser({
    required String email,
    required String nickname,
    required String password,
  });

  Future<bool> isAuthorized();

  Future<void> loginUser({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> me();
}
