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
        FirestoreKeys.removedPlayersTempIdsFieldKey: removedPlayers,
        FirestoreKeys.mutedPlayersTempIdsFieldKey: mutedPlayers,
        FirestoreKeys.playersWithFoulTempIdsFieldKey: playersWithFoul,
      };

  DayInfoEntity.fromFirestoreMap({
    required this.id,
    required this.removedPlayers,
    required this.mutedPlayers,
    required this.playersWithFoul,
    required Map<String, dynamic> data,
  })  : tempId = data[FirestoreKeys.tempIdFieldKey],
        gameId = data[FirestoreKeys.gameIdFieldKey],
        day = data[FirestoreKeys.dayInfoDayFieldKey],
        createdAt = DateTime.fromMillisecondsSinceEpoch(data[FirestoreKeys.createdAtFieldKey] ?? 0);
}
