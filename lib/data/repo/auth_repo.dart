import 'package:mafia_board/data/api/auth_api.dart';
import 'package:mafia_board/data/api/model/user_api_model.dart';
import 'package:mafia_board/data/api/token_provider.dart';

class AuthRepo {
  static const String tag = 'AuthRepo';

  final AuthApi api;
  final TokenProvider tokenProvider;

  AuthRepo({required this.api, required this.tokenProvider});

  Future<UserApiModel?> registerUser({
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

  Future<bool> isAuthorized() async => tokenProvider.token != null;

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final result = await api.login(email: email, password: password);
    await tokenProvider.setToken(result.token);
  }

  Future<void> logout() async {
    await api.logout();
    await tokenProvider.deleteToken();
  }

  Future<UserApiModel?> me() async {
    return await api.me();
  }
}
