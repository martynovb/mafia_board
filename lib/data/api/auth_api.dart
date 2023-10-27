import 'package:mafia_board/data/api/model/token_api_model.dart';
import 'package:mafia_board/data/api/model/user_api_model.dart';
import 'package:mafia_board/data/api/network_manager.dart';

class AuthApi {
  final NetworkManager _networkManager;

  static const _authPath = 'api/v1/auth';

  AuthApi(this._networkManager);

  /// *************************************************************
  /// AUTH API

  Future<dynamic> logout() => _networkManager.post('$_authPath/token/logout');

  Future<UserApiModel> me() => _networkManager.get('$_authPath/users/me').then(
        (result) => UserApiModel.fromJson(result),
      );

  Future<TokenApiModel> login({
    required String email,
    required String password,
  }) =>
      _networkManager.post(
        '$_authPath/token/login/',
        body: {
          'email': email,
          'password': password,
        },
      ).then(
        (result) => TokenApiModel.fromJson(result),
      );

  Future<TokenApiModel> register({
    required String email,
    required String username,
    required String password,
  }) =>
      _networkManager.post(
        '$_authPath/users/',
        body: {
          'email': email,
          'username': username,
          'password': password,
        },
      ).then(
        (result) => TokenApiModel.fromJson(result),
      );
}
