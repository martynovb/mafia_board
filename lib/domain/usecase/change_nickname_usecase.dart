import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class ChangeNicknameUseCase extends BaseUseCase<UserModel?, String> {
  final AuthRepo authRepo;

  ChangeNicknameUseCase({required this.authRepo});

  @override
  Future<UserModel?> execute({String? params}) async {
    final entity = await authRepo.changeNickname(nickname: params!);
    return UserModel.fromEntity(entity);
  }
}
