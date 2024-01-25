import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetAllClubMembersUsecase
    extends BaseUseCase<List<ClubMemberModel>, ClubModel> {
  final ClubsRepo clubsRepo;

  GetAllClubMembersUsecase({
    required this.clubsRepo,
  });

  @override
  Future<List<ClubMemberModel>> execute({ClubModel? params}) async {
    final allClubMembers =
        await clubsRepo.getExistedAndNotExistedClubMembers(clubModel: params!);
    return allClubMembers
        .map((entity) => ClubMemberModel.fromEntity(entity))
        .toList();
  }
}
