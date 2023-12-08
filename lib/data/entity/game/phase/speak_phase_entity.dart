import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/data/entity/game/phase/game_phase_entity.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/utils/date_format_util.dart';

class SpeakPhaseEntity extends GamePhaseEntity {
  final String? playerId;
  final bool? isLastWord;
  final bool? isGunfight;
  final bool? isBestMove;
  final List<int>? bestMove;

  SpeakPhaseEntity({
    required String? id,
    required int? currentDay,
    required String? status,
    required DateTime? createdAt,
    required String? type,
    required this.playerId,
    required this.isLastWord,
    required this.isGunfight,
    required this.isBestMove,
    required this.bestMove,
  }) : super(
          id: id,
          currentDay: currentDay,
          status: status,
          createdAt: createdAt,
          type: type,
        );

  static SpeakPhaseEntity fromJson(Map<String, dynamic> json) {
    return SpeakPhaseEntity(
      id: json['id'],
      currentDay: json['current_day'],
      createdAt:
          DateFormatUtil.convertStringToDate(json['created_at'] as String?),
      status: json['status'],
      type: json['type'],
      playerId: json['player_id'],
      isLastWord: json['is_last_word'],
      isGunfight: json['is_gunfight'],
      isBestMove: json['is_best_move'],
      bestMove:
          json['bestMove'] != null ? List<int>.from(json['best_move']) : null,
    );
  }
}
