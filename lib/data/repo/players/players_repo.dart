import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';

abstract class PlayersRepo {
  Future<List<PlayerEntity>> savePlayers({required String gameId});

  List<PlayerModel> createPlayers(int count);

  void setUser(int seatNumber, ClubMemberModel clubMember);

  List<PlayerModel> getAllPlayers();

  Future<List<PlayerModel>> getAllPlayersByRole(List<Role> roles);

  List<PlayerModel> getAllAvailablePlayers();

  Future<PlayerModel?> getPlayerByTempId(String tempId);

  Future<PlayerModel?> getPlayerByNumber(int index);

  Future<void> updatePlayer(
    String id, {
    int? fouls,
    Role? role,
    bool? isRemoved,
    bool? isKilled,
    bool? isKicked,
    bool? isMuted,
    bool? isPPK,
  });

  Future<void> updateAllPlayerData(PlayerModel playerToUpdate);

  void resetAll();

  Future<void> deleteAllPlayersByGameId({required String gameId});

  Future<List<PlayerEntity>> fetchAllPlayersByGameId({required String gameId});

  Future<List<PlayerEntity>> fetchAllPlayersByMemberId({required String memberId});
}
