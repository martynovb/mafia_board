import 'package:collection/collection.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/user_model.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';

class PlayersRepoLocal extends PlayersRepo {
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
    PlayerModel player = PlayerModel(user, Role.NONE, seatNumber);
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
  void resetAll() {
    for (var player in _players) {
      player.reset();
    }
  }

  @override
  Future<PlayerModel?> getPlayerById(String id) async {
    return _players.firstWhereOrNull((player) => player.id == id);
  }
}
