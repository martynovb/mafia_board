import 'package:mafia_board/data/entity/user_entity.dart';

abstract class AuthRepo {
  Future<UserEntity> registerUser({
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

  Future<UserEntity> me();

  Future<UserEntity> changeNickname({
    required String nickname,
  });
}
