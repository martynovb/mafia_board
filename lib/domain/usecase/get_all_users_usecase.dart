import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetAllUsersUsecase extends BaseUseCase<List<UserModel>, void> {
  final UsersRepo usersRepo;

  GetAllUsersUsecase({required this.usersRepo});

  @override
  Future<List<UserModel>> execute({void params}) async {
    final allUsers = await usersRepo.getAllUsers();
    return allUsers.map((user) => UserModel.fromEntity(user)).toList() ?? [];
  }
}