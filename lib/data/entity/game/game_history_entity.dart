import 'package:mafia_board/data/entity/game/phase/game_phase_entity.dart';
import 'package:mafia_board/data/entity/game/phase/night_phase_entity.dart';
import 'package:mafia_board/data/entity/game/phase/speak_phase_entity.dart';
import 'package:mafia_board/data/entity/game/phase/vote_phase_entity.dart';
import 'package:mafia_board/domain/utils/date_format_util.dart';

class GameHistoryEntity {
  final String? id;
  final String? text;
  final String? subText;
  final String? type;
  final GamePhaseEntity? gamePhaseEntity;
  final DateTime? createdAt;

  GameHistoryEntity({
    required this.id,
    required this.text,
    required this.subText,
    required this.type,
    required this.gamePhaseEntity,
    required this.createdAt,
  });

  static GameHistoryEntity fromJson(Map<dynamic, dynamic> json) {
    GamePhaseEntity? parseGamePhaseEntity(Map<String, dynamic>? phaseJson) {
      if (phaseJson == null) {
        return null;
      }

      String phaseType = phaseJson['type'];
      switch (phaseType) {
        case 'speak':
          return SpeakPhaseEntity.fromJson(phaseJson);
        case 'vote':
          return VotePhaseEntity.fromJson(phaseJson);
        case 'night':
          return NightPhaseEntity.fromJson(phaseJson);
        default:
          throw Exception('Unknown phase type: $phaseType');
      }
    }

    return GameHistoryEntity(
      id: json['id'] as String?,
      text: json['text'] as String?,
      subText: json['subText'] as String?,
      type: json['type'] as String?,
      gamePhaseEntity: parseGamePhaseEntity(json['game_phase']),
      createdAt: DateFormatUtil.convertStringToDate(json['created_at']),
    );
  }

  static List<GameHistoryEntity> parseEntities(dynamic data) {
    if (data is! List) {
      return [];
    }
    return data
        .map<GameHistoryEntity>((e) => GameHistoryEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
