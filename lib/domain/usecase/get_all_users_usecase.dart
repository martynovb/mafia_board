import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetAllClubMembersUsecase
    extends BaseUseCase<List<ClubMemberModel>, String> {
  final ClubsRepo clubsRepo;

  GetAllClubMembersUsecase({
    required this.clubsRepo,
  });

  @override
  Future<List<ClubMemberModel>> execute({String? params}) async {
    final allClubMembers =
        await clubsRepo.getExistedAndNotExistedClubMembers(clubId: params!);
    return allClubMembers
        .map((entity) => ClubMemberModel.fromEntity(entity))
        .toList();
  }
}
