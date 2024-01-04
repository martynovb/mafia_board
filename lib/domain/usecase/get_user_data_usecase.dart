import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetUserDataUseCase extends BaseUseCase<UserModel?, void> {
  final AuthRepo authRepo;

  GetUserDataUseCase({required this.authRepo});

  @override
  Future<UserModel?> execute({void params}) async {
    final entity = await authRepo.me();
    return UserModel.fromEntity(entity);
  }
}
