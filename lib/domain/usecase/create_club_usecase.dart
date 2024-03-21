import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class CreateClubUseCase extends BaseUseCase<ClubModel, CreateClubParams> {
  final ClubsRepo clubsRepo;

  CreateClubUseCase({
    required this.clubsRepo,
  });

  @override
  Future<ClubModel> execute({CreateClubParams? params}) async {
    final clubEntity = await clubsRepo.createClub(
      name: params!.name,
      clubDescription: params.clubDescription,
    );
    return ClubModel.fromEntity(clubEntity);
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
