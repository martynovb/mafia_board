import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetClubDetailsUseCase extends BaseUseCase<ClubModel, String> {
  final AuthRepo authRepo;
  final ClubsRepo clubsRepo;

  GetClubDetailsUseCase({
    required this.authRepo,
    required this.clubsRepo,
  });

  @override
  Future<ClubModel> execute({String? params}) async {
    final me = await authRepo.me();
    final entity = await clubsRepo.getClubDetails(id: params!);
    return ClubModel.fromEntity(
      entity!,
      entity.admins?.any((user) => user.id == me.id) ?? false,
    );
  }
}
