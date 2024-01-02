import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:uuid/uuid.dart';

class AuthRepoLocal extends AuthRepo {
  bool _isAuthorized = true;

  final UserEntity currentUser = UserEntity(
      id: const Uuid().v1(), nickname: 'Magic', email: 'magic@gmail.com');

  AuthRepoLocal();

  @override
  Future<UserEntity> me() async {
    return currentUser;
  }

  @override
  Future<bool> isAuthorized() async => _isAuthorized;

  @override
  Future<void> loginUser({required String email, required String password}) {
    _isAuthorized = true;
    return Future.value();
  }

  @override
  Future<void> logout() {
    _isAuthorized = false;
    return Future.value();
  }

  @override
  Future<UserEntity> registerUser({
    required String email,
    required String nickname,
    required String password,
  }) async {
    _isAuthorized = true;
    return currentUser;
  }

  @override
  Future<UserEntity> registerUserWithGoogle() async {
    _isAuthorized = true;
    return currentUser;
  }
}
