import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetAllClubsUseCase extends BaseUseCase<List<ClubModel>, void> {
  final ClubsRepo clubsRepo;

  GetAllClubsUseCase({
    required this.clubsRepo,
  });

  @override
  Future<List<ClubModel>> execute({void params}) async {
    final clubs = await clubsRepo.getAllClubs();
    return clubs.map((club) => ClubModel.fromEntity(club)).toList();
  }
}
