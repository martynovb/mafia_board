import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:uuid/uuid.dart';

abstract class GamePhaseModel {
  String? id;
  final String tempId;
  String? dayInfoId;
  String? gameId;
  final int currentDay;
  DateTime updatedAt = DateTime.now();
  PhaseStatus status;
  abstract final PhaseType phaseType;

  GamePhaseModel({
    this.id,
    this.gameId,
    this.dayInfoId,
    required this.currentDay,
    required this.tempId,
    this.status = PhaseStatus.notStarted,
  });

  set updateStatus(PhaseStatus status) {
    this.status = status;
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toFirestoreMap() => {
        FirestoreKeys.tempIdFieldKey: tempId,
        FirestoreKeys.dayInfoIdFieldKey: dayInfoId,
        FirestoreKeys.gameIdFieldKey: gameId,
        FirestoreKeys.gamePhaseDayFieldKey: currentDay,
        FirestoreKeys.updatedAtFieldKey: updatedAt.millisecondsSinceEpoch,
        FirestoreKeys.gamePhaseTypeFieldKey: phaseType.name,
      };

  static List<GamePhaseModel> fromListMap(dynamic data) {
    if (data == null || data.isEmpty) {
      return [];
    }
    return (data as List<dynamic>).map((v) {
      if (v['phaseType'] == PhaseType.night.name) {
        return NightPhaseModel.fromMap(map: v);
      } else if (v['phaseType'] == PhaseType.speak.name) {
        return SpeakPhaseModel.fromMap(map: v);
      } else if (v['phaseType'] == PhaseType.vote.name) {
        return VotePhaseModel.fromMap(map: v);
      }
      throw ArgumentError('Unexpected game phase type: $v');
    }).toList();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tempId': tempId,
        'dayInfoId': dayInfoId,
        'gameId': gameId,
        'currentDay': currentDay,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'phaseType': phaseType.name,
      };
}
