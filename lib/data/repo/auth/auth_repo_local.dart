import 'package:mafia_board/data/model/user_model.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:uuid/uuid.dart';

class AuthRepoLocal extends AuthRepo {
  bool _isAuthorized = true;

  final UserModel currentUser = UserModel(
      id: const Uuid().v1(), nickname: 'Magic', email: 'magic@gmail.com');

  AuthRepoLocal();

  @override
  Future<UserModel> me() async {
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
  Future<UserModel> registerUser({
    required String email,
    required String nickname,
    required String password,
  }) async {
    _isAuthorized = true;
    return currentUser;
  }
}
