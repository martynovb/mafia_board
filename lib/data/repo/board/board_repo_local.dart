import 'package:collection/collection.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/model/user_model.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:uuid/uuid.dart';

class BoardRepoLocal extends BoardRepo {
  final List<PlayerModel> _players = [];

  @override
  List<PlayerModel> createPlayers(int count) {
    _players.clear();
    for (int i = 1; i <= count; i++) {
      _players.add(PlayerModel.empty(i));
    }
    return _players;
  }

  @override
  void setUser(int seatNumber, UserModel user) {
    final playerIndex =
        _players.indexWhere((player) => player.seatNumber == seatNumber);
    PlayerModel player = _players[playerIndex];
    player.user = user;
    _players[playerIndex] = player;
  }

  @override
  List<PlayerModel> getAllPlayers() => _players;

  @override
  List<PlayerModel> getAllAvailablePlayers() => _players
      .where(
          (player) => !player.isKilled && !player.isRemoved && !player.isKicked)
      .toList();

  @override
  Future<PlayerModel?> getPlayerByNumber(int number) async =>
      _players.firstWhereOrNull((player) => player.seatNumber == number);

  @override
  Future<void> updatePlayer(
    String id, {
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
    player.fouls = fouls ?? player.fouls;
    player.role = role ?? player.role;
    player.score = score ?? player.score;
    player.score = score ?? player.score;
    player.isRemoved = isRemoved ?? player.isRemoved;
    player.isKilled = isKilled ?? player.isKilled;
    player.isKicked = isKicked ?? player.isKicked;
    player.isMuted = isMuted ?? player.isMuted;
    _players[playerIndex] = player;
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
  Future<PlayerModel?> getPlayerById(String id) async {
    return _players.firstWhereOrNull((player) => player.id == id);
  }
}
