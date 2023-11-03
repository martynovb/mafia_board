import 'package:collection/collection.dart';
import 'package:mafia_board/data/model/user_model.dart';
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
  Future<List<UserModel>> getAllUsers() async => _users;

  @override
  Future<UserModel?> getUserById(String id) async =>
      _users.firstWhereOrNull((user) => user.id == id);

  final List<UserModel> _users = [
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Doc',
      email: 'doc@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Veritas',
      email: 'veritas@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Kolpak',
      email: 'kolpak@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Masyanya',
      email: 'masyanya@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'L',
      email: 'l@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Diavolonok',
      email: 'diavolonok@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Sifer',
      email: 'sifer@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Greshnik',
      email: 'greshnik@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'Lastochka',
      email: 'lastochka@gmail.com',
    ),
    UserModel(
      id: const Uuid().v1(),
      nickname: 'F1boy',
      email: 'f1boy@gmail.com',
    ),
  ];
}
