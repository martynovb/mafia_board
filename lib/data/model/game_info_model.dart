import 'package:mafia_board/data/model/player_model.dart';

class GameInfoModel {
  final int id = DateTime.now().millisecondsSinceEpoch;
  final int day;
  final DateTime createdAt = DateTime.now();
  final List<PlayerModel> _mutedPlayers = [];
  final List<PlayerModel> _playersWithFoul = [];

  GameInfoModel({required this.day});

  void addMutedPlayer(PlayerModel player) => _mutedPlayers.add(player);

  void addAllPlayersWithFoul(List<PlayerModel> players) =>
      _playersWithFoul.addAll(players);

  List<PlayerModel> get playersWithFoul => _playersWithFoul;

  List<PlayerModel> get mutedPlayers => _mutedPlayers;
}
