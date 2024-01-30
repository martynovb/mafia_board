import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class DayInfoModel {
  final String id;
  final String gameId;
  final int day;
  final DateTime createdAt;
  final List<PlayerModel> removedPlayers;
  final List<PlayerModel> mutedPlayers;
  final List<PlayerModel> playersWithFoul;
  PhaseType currentPhase;

  DayInfoModel.fromEntity(DayInfoEntity? entity)
      : id = entity?.tempId ?? '',
        gameId = entity?.gameId ?? '',
        day = entity?.day ?? -1,
        createdAt = entity?.createdAt ?? DateTime.now(),
        removedPlayers = entity?.removedPlayers
                ?.map(
                  (playerEntity) => PlayerModel.fromEntity(playerEntity),
                )
                .toList() ??
            [],
        mutedPlayers = entity?.mutedPlayers
                ?.map(
                  (playerEntity) => PlayerModel.fromEntity(playerEntity),
                )
                .toList() ??
            [],
        playersWithFoul = entity?.playersWithFoul
                ?.map(
                  (playerEntity) => PlayerModel.fromEntity(playerEntity),
                )
                .toList() ??
            [],
        currentPhase = phaseTypeMapper(entity?.currentPhase);

  DayInfoEntity toEntity() => DayInfoEntity(
        tempId: id,
        gameId: gameId,
        day: day,
        createdAt: createdAt,
        removedPlayers:
            removedPlayers.map((player) => player.toEntity()).toList(),
        mutedPlayers: mutedPlayers.map((player) => player.toEntity()).toList(),
        playersWithFoul:
            playersWithFoul.map((player) => player.toEntity()).toList(),
        currentPhase: currentPhase.name,
      );

  void addMutedPlayer(PlayerModel player) => mutedPlayers.add(player);

  void addRemovedPlayer(PlayerModel player) => removedPlayers.add(player);

  void addAllPlayersWithFoul(List<PlayerModel> players) =>
      playersWithFoul.addAll(players);

  List<PlayerModel> get getPlayersWithFoul => playersWithFoul;

  bool get isRemovedPlayer => removedPlayers.isNotEmpty;

  List<PlayerModel> get getMutedPlayers => mutedPlayers;

  void removedMutedPlayer(String id) =>
      mutedPlayers.removeWhere((player) => player.tempId == id);

  void removedRemovedPlayer(String id) =>
      removedPlayers.removeWhere((player) => player.tempId == id);

  @override
  String toString() {
    return (ClassToString('DayInfoModel')
          ..add('id', id)
          ..add('gameId', gameId)
          ..add('day', day)
          ..add('createdAt', createdAt)
          ..add('removedPlayers', removedPlayers.length)
          ..add('mutedPlayers', mutedPlayers.length))
        .toString();
  }
}
