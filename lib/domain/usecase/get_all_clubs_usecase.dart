import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetAllClubsUseCase extends BaseUseCase<List<ClubModel>, String> {
  final ClubsRepo clubsRepo;

  GetAllClubsUseCase({
    required this.clubsRepo,
  });

  @override
  Future<List<ClubModel>> execute({String? params}) async {
    final clubs = await clubsRepo.getClubs(id: params);
    return clubs.map((club) => ClubModel.fromEntity(club)).toList();
  }
}
