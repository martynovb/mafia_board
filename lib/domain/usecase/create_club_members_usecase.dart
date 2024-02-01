import 'package:mafia_board/data/entity/club_member_entity.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class CreateClubMembersUseCase
    extends BaseUseCase<List<ClubMemberEntity>, String> {
  final PlayersRepo playersRepo;
  final ClubsRepo clubsRepo;

  CreateClubMembersUseCase({
    required this.playersRepo,
    required this.clubsRepo,
  });

  ///where @params is clubId
  @override
  Future<List<ClubMemberEntity>> execute({String? params}) async {
    final membersToAdd = playersRepo
        .getAllPlayers()
        .where((player) => player.clubMember != null)
        .map((player) => player.clubMember!)
        .where((member) => member.id == null)
        .map((member) => member.toEntity())
        .toList();
    return clubsRepo.addNewMembers(
      clubId: params!,
      newMembers: membersToAdd,
    );
  }
}
