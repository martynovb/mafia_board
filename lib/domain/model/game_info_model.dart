import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class GameInfoModel {
  final int id = DateTime.now().millisecondsSinceEpoch;
  final int day;
  final DateTime createdAt = DateTime.now();
  final List<PlayerModel> _removedPlayers = [];
  final List<PlayerModel> _mutedPlayers = [];
  final List<PlayerModel> _playersWithFoul = [];
  PhaseType currentPhase;
  bool isGameStarted;

  GameInfoModel({
    required this.day,
    this.currentPhase = PhaseType.none,
    this.isGameStarted = true,
  });

  void addMutedPlayer(PlayerModel player) => _mutedPlayers.add(player);

  void addRemovedPlayer(PlayerModel player) => _removedPlayers.add(player);

  void addAllPlayersWithFoul(List<PlayerModel> players) =>
      _playersWithFoul.addAll(players);

  List<PlayerModel> get playersWithFoul => _playersWithFoul;

  bool get isRemovedPlayer => _removedPlayers.isNotEmpty;

  List<PlayerModel> get mutedPlayers => _mutedPlayers;

  void removedMutedPlayer(String id) =>
      _mutedPlayers.removeWhere((player) => player.id == id);

  void removedRemovedPlayer(String id) =>
      _removedPlayers.removeWhere((player) => player.id == id);
}
