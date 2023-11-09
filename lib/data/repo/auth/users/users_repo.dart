import 'package:mafia_board/domain/model/user_model.dart';

abstract class UsersRepo {
  Future<List<UserModel>> getAllUsers();

  Future<UserModel?> getUserById(String id);
}
