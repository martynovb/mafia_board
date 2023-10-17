import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';

abstract class BoardRepo {
  List<PlayerModel> createPlayers(int count);
  List<PlayerModel> getAllPlayers();

  List<PlayerModel> getAllAvailablePlayers();

  Future<PlayerModel?> getPlayerById(int id);

  Future<PlayerModel?> getPlayerByIndex(int index);

  Future<void> updatePlayer(
    int id, {
    String? nickname,
    int? fouls,
    Role? role,
    double? score,
    bool? isRemoved,
    bool? isKilled,
    bool? isKicked,
    bool? isMuted,
  });

  void deleteAll();
}
