import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/utils/date_format_util.dart';

class DayInfoEntity {
  final String? id;
  final String? gameId;
  final int? day;
  final DateTime? createdAt;
  final List<PlayerEntity>? removedPlayers;
  final List<PlayerEntity>? mutedPlayers;
  final List<PlayerEntity>? playersWithFoul;
  final String? currentPhase;

  DayInfoEntity({
    required this.id,
    required this.gameId,
    required this.day,
    required this.createdAt,
    required this.removedPlayers,
    required this.mutedPlayers,
    required this.playersWithFoul,
    required this.currentPhase,
  });

  static DayInfoEntity fromJson(Map<dynamic, dynamic> json) {
    return DayInfoEntity(
      id: json['id'] as String?,
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
        .map<DayInfoEntity>((e) => DayInfoEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
