import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';

class BoardRepository {
  final List<PlayerModel> _players = [];

  List<PlayerModel> createPlayers(int count) {
    _players.clear();
    for (int i = 0; i < count; i++) {
      _players.add(PlayerModel.empty(id: i));
    }
    return _players;
  }

  List<PlayerModel> getAllPlayers() => _players;

  List<PlayerModel> getAllAvailablePlayers() => _players
      .where((player) => !player.isKilled && !player.isRemoved && !player.isKicked)
      .toList();

  Future<PlayerModel?> getPlayerByIndex(int index) async => _players[index];

  Future<void> setPlayer(int index, PlayerModel playerModel) async {
    _players[index] = playerModel;
  }

  Future<void> updatePlayer(
    int id, {
    String? nickname,
    int? fouls,
    Role? role,
    double? score,
    bool? isRemoved,
    bool? isKilled,
    bool? isKicked,
  }) async {
    int playerIndex = _players.indexWhere((player) => player.id == id);
    PlayerModel player = _players[playerIndex];
    final newPlayerData = PlayerModel(
      id,
      nickname ?? player.nickname,
      fouls ?? player.fouls,
      role ?? player.role,
      score ?? player.score,
      isRemoved: isRemoved ?? player.isRemoved,
      isKilled: isKilled ?? player.isKilled,
    );

    _players[playerIndex] = newPlayerData;

    print(newPlayerData.toString());
  }
}
