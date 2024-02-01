import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:uuid/uuid.dart';

abstract class GamePhaseModel {
  String? id;
  final String tempId = const Uuid().v1();
  String? dayInfoId;
  String? gameId;
  final int currentDay;
  DateTime updatedAt = DateTime.now();
  PhaseStatus status;
  abstract final PhaseType phaseType;

  GamePhaseModel({
    this.id,
    required this.currentDay,
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
}
