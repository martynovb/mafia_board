import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class UpdateClubUseCase extends BaseUseCase<ClubModel, UpdateClubParams> {
  final ClubsRepo clubsRepo;

  UpdateClubUseCase({
    required this.clubsRepo,
  });

  @override
  Future<ClubModel> execute({UpdateClubParams? params}) async {
    final clubEntity = await clubsRepo.updateClub(
      id: params!.id,
      name: params.name,
      description: params.description,
    );
    return ClubModel.fromEntity(
      clubEntity,
    );
  }
}

class UpdateClubParams {
  final String id;
  final String name;
  final String description;

  UpdateClubParams({
    required this.id,
    required this.name,
    required this.description,
  });
}
