import 'package:mafia_board/data/entity/game/phase/game_phase_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';
import 'package:mafia_board/domain/utils/date_format_util.dart';

class NightPhaseEntity extends GamePhaseEntity {
  final String? role;
  final List<PlayerEntity>? playersForWakeUp;
  PlayerEntity? killedPlayer;
  PlayerEntity? checkedPlayer;

  NightPhaseEntity({
    required String? id,
    required int? currentDay,
    required String? status,
    required DateTime? createdAt,
    required String? type,
    required this.role,
    required this.playersForWakeUp,
    required this.killedPlayer,
    required this.checkedPlayer,
  }) : super(
          id: id,
          currentDay: currentDay,
          status: status,
          createdAt: createdAt,
          type: type,
        );

  static NightPhaseEntity fromJson(Map<dynamic, dynamic> json) {
    return NightPhaseEntity(
      id: json['id'] as String?,
      currentDay: json['currentDay'] as int?,
      createdAt: DateFormatUtil.convertStringToDate(json['createdAt']),
      status: json['status'] as String?,
      type: json['type'] as String?,
      role: json['role'] as String?,
      playersForWakeUp:
          PlayerEntity.parsePlayerEntities(json['players_for_wake_up']),
      killedPlayer: PlayerEntity.fromJson(json['killed_player']),
      checkedPlayer: PlayerEntity.fromJson(json['checked_player']),
    );
  }
}
