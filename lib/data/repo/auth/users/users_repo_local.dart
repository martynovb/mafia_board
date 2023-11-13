import 'package:collection/collection.dart';
import 'package:mafia_board/data/entity/user_entity.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:uuid/uuid.dart';

class UsersRepoLocal extends UsersRepo {
  final AuthRepo authRepo;

  UsersRepoLocal({required this.authRepo}) {
    _addCurrentUser();
  }

  Future _addCurrentUser() async {
    _users.add(await authRepo.me());
  }

  @override
  Future<List<UserEntity>> getAllUsers() async => _users;

  @override
  Future<UserEntity?> getUserById(String id) async =>
      _users.firstWhereOrNull((user) => user.id == id);

  final List<UserEntity> _users = [
    UserEntity(
      id: const Uuid().v1(),
      username: 'Doc',
      email: 'doc@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'Veritas',
      email: 'veritas@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'Kolpak',
      email: 'kolpak@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'Masyanya',
      email: 'masyanya@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'L',
      email: 'l@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'Diavolonok',
      email: 'diavolonok@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'Sifer',
      email: 'sifer@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'Greshnik',
      email: 'greshnik@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'Lastochka',
      email: 'lastochka@gmail.com',
    ),
    UserEntity(
      id: const Uuid().v1(),
      username: 'F1boy',
      email: 'f1boy@gmail.com',
    ),
  ];
}
