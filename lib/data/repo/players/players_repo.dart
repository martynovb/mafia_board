import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/user_model.dart';

abstract class PlayersRepo {

  List<PlayerModel> createPlayers(int count);

  void setUser(int seatNumber, UserModel user);

  List<PlayerModel> getAllPlayers();

  List<PlayerModel> getAllAvailablePlayers();

  Future<PlayerModel?> getPlayerById(String id);

  Future<PlayerModel?> getPlayerByNumber(int index);

  Future<void> updatePlayer(
    String id, {
    int? fouls,
    Role? role,
    double? score,
    bool? isRemoved,
    bool? isKilled,
    bool? isKicked,
    bool? isMuted,
  });

  void resetAll();
}
