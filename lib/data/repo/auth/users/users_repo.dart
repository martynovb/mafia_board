import 'package:mafia_board/data/entity/user_entity.dart';

abstract class UsersRepo {
  Future<List<UserEntity>> getAllUsers();

  Future<UserEntity?> getUserById(String id);

  Future<List<UserEntity>?> getUsersByIds(List<String> ids);
}
