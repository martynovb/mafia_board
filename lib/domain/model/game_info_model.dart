import 'package:class_to_string/class_to_string.dart';
import 'package:collection/collection.dart';
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

  DayInfoModel({
    required this.id,
    required this.gameId,
    required this.day,
    required this.createdAt,
    required this.removedPlayers,
    required this.mutedPlayers,
    required this.playersWithFoul,
    required this.currentPhase,
  });

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'gameId': gameId,
        'day': day,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'removedPlayers':
            removedPlayers.map((player) => player.toMap()).toList(),
        'mutedPlayers': mutedPlayers.map((player) => player.toMap()).toList(),
        'playersWithFoul':
            playersWithFoul.map((player) => player.toMap()).toList(),
        'currentPhase': currentPhase.name,
      };

  static List<DayInfoModel> fromListMap(dynamic data) {
    if (data == null || data.isEmpty) {
      return [];
    }
    return (data as List<dynamic>)
        .map((map) => DayInfoModel.fromMap(map))
        .toList();
  }

  static DayInfoModel fromMap(Map<String, dynamic> map) => DayInfoModel(
        id: map['id'] ?? '',
        gameId: map['gameId'] ?? '',
        day: map['day'] ?? -1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
        removedPlayers: PlayerModel.fromListMap(map['removedPlayers']),
        mutedPlayers: PlayerModel.fromListMap(map['mutedPlayers']),
        playersWithFoul: PlayerModel.fromListMap(map['playersWithFoul']),
        currentPhase: PhaseType.values.firstWhereOrNull(
                (phase) => map['currentPhase'] == phase.name) ??
            PhaseType.none,
      );

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
