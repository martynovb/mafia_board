import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/utils/date_format_util.dart';

class DayInfoEntity {
  String? id;
  final String? tempId;
  String? gameId;
  final int? day;
  final DateTime? createdAt;
  final List<PlayerEntity>? removedPlayers;
  final List<PlayerEntity>? mutedPlayers;
  final List<PlayerEntity>? playersWithFoul;
  String? currentPhase;

  DayInfoEntity({
    this.id,
    required this.tempId,
    this.gameId,
    required this.day,
    required this.createdAt,
    required this.removedPlayers,
    required this.mutedPlayers,
    required this.playersWithFoul,
    required this.currentPhase,
  });

  Map<String, dynamic> toFirestoreMap() => {
        FirestoreKeys.tempIdFieldKey: tempId,
        FirestoreKeys.gameIdFieldKey: gameId,
        FirestoreKeys.dayInfoDayFieldKey: day,
        FirestoreKeys.createdAtFieldKey: createdAt?.millisecondsSinceEpoch,
        FirestoreKeys.removedPlayersTempIdsFieldKey: removedPlayers
            ?.map(
              (player) => player.tempId,
            )
            .toList(),
        FirestoreKeys.mutedPlayersTempIdsFieldKey: mutedPlayers
            ?.map(
              (player) => player.tempId,
            )
            .toList(),
        FirestoreKeys.playersWithFoulTempIdsFieldKey: playersWithFoul
            ?.map(
              (player) => player.tempId,
            )
            .toList(),
      };

  static DayInfoEntity fromJson(Map<dynamic, dynamic> json) {
    return DayInfoEntity(
      id: json['id'] as String?,
      tempId: json['tempId'] as String?,
      gameId: json['gameId'] as String?,
      day: json['day'] as int?,
      createdAt: DateFormatUtil.convertStringToDate(json['createdAt']),
      removedPlayers: PlayerEntity.parsePlayerEntities(json['removed_players']),
      mutedPlayers: PlayerEntity.parsePlayerEntities(json['muted_players']),
      playersWithFoul:
          PlayerEntity.parsePlayerEntities(json['players_with_foul']),
      currentPhase: json['currentPhase'] as String?,
    );
  }

  static List<DayInfoEntity> parseEntities(dynamic data) {
    if (data is! List) {
      return [];
    }
    return data
        .map<DayInfoEntity>(
            (e) => DayInfoEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
