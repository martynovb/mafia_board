import 'package:collection/collection.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';

class BoardRepoLocal extends BoardRepo {
  final List<PlayerModel> _players = [];

  @override
  List<PlayerModel> createPlayers(int count) {
    _players.clear();
    for (int i = 0; i < count; i++) {
      _players.add(PlayerModel.empty(id: i));
    }
    return _players;
  }

  @override
  List<PlayerModel> getAllPlayers() => _players;

  @override
  List<PlayerModel> getAllAvailablePlayers() => _players
      .where(
          (player) => !player.isKilled && !player.isRemoved && !player.isKicked)
      .toList();

  @override
  Future<PlayerModel?> getPlayerByIndex(int index) async => _players[index];

  @override
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
      isKicked: isKicked ?? player.isKicked,
      isMuted: isMuted ?? player.isMuted,
    );

    _players[playerIndex] = newPlayerData;
  }

  @override
  void deleteAll() {
    for (var element in _players) {
      element.isRemoved = false;
      element.isKilled = false;
      element.isMuted = false;
      element.isKicked = false;
      element.fouls = 0;
    }
  }

  @override
  Future<PlayerModel?> getPlayerById(int id) async {
    return _players.firstWhereOrNull((player) => player.id == id);
  }
}
