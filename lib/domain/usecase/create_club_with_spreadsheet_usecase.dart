import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class CreateClubWithSpreadSheetUseCase extends BaseUseCase<ClubModel, CreateClubParams> {
  final AuthRepo authRepo;
  final ClubsRepo clubsRepo;

  CreateClubWithSpreadSheetUseCase({
    required this.authRepo,
    required this.clubsRepo,
  });

  @override
  Future<ClubModel> execute({CreateClubParams? params}) async {
    final me = await authRepo.me();
    final clubEntity = await clubsRepo.createClubWithGoogleTable(
      name: params!.name,
      clubDescription: params.clubDescription,
    );
    return ClubModel.fromEntity(
      clubEntity,
      clubEntity.admins?.any((player) => player.id == me.id) ?? false,
    );
  }
}

class CreateClubParams {
  final String name;
  final String clubDescription;

  CreateClubParams({
    required this.name,
    required this.clubDescription,
  });
}
