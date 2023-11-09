import 'package:mafia_board/data/api/auth_api.dart';
import 'package:mafia_board/data/api/token_provider.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';

class AuthRepoRemote extends AuthRepo {
  static const String tag = 'AuthRepoRemote';

  final AuthApi api;
  final TokenProvider tokenProvider;

  AuthRepoRemote({required this.api, required this.tokenProvider});

  @override
  Future<UserModel> registerUser({
    required String email,
    required String nickname,
    required String password,
  }) async {
    final result = await api.register(
      email: email,
      username: nickname,
      password: password,
    );
    await tokenProvider.setToken(result.token);
    return await me();
  }

  @override
  Future<bool> isAuthorized() async => true;

  @override
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final result = await api.login(email: email, password: password);
    await tokenProvider.setToken(result.token);
  }

  @override
  Future<void> logout() async {
    await api.logout();
    await tokenProvider.deleteToken();
  }

  @override
  Future<UserModel> me() async {
    final userApiModel = await api.me();
    return UserModel(
      id: userApiModel.id!,
      nickname: userApiModel.username!,
      email: userApiModel.email!,
    );
  }
}
