import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetAllClubsUseCase extends BaseUseCase<Future<List<ClubModel>>, String> {
  final ClubsRepo clubsRepo;

  GetAllClubsUseCase({
    required this.clubsRepo,
  });

  @override
  Future<List<ClubModel>> execute({String? params}) async {
    return clubsRepo.getClubs(id: params);
  }


}
