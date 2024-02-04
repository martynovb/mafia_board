import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class SpeakPhaseModel extends GamePhaseModel {
  final String? playerTempId;
  Duration timeForSpeakInSec;
  bool isLastWord;
  bool isGunfight;
  bool isBestMove;
  List<PlayerModel> bestMove;

  SpeakPhaseModel({
    super.id,
    required super.currentDay,
    required super.tempId,
    required this.playerTempId,
    super.gameId,
    this.timeForSpeakInSec = Constants.defaultTimeForSpeak,
    super.status = PhaseStatus.notStarted,
    this.isLastWord = false,
    this.isGunfight = false,
    this.isBestMove = false,
    this.bestMove = const [],
  });

  @override
  PhaseType get phaseType => PhaseType.speak;

  static SpeakPhaseModel fromFirebaseMap({
    required String id,
    required List<PlayerModel> bestMove,
    required Map<String, dynamic> map,
  }) {
    return SpeakPhaseModel(
      id: id,
      playerTempId: map[FirestoreKeys.speakPhasePlayerTempIdFieldKey],
      tempId: map[FirestoreKeys.tempIdFieldKey],
      currentDay: map[FirestoreKeys.gamePhaseDayFieldKey],
      gameId: map[FirestoreKeys.gameIdFieldKey],
      status: PhaseStatus.finished,
      isLastWord: map[FirestoreKeys.speakPhaseIsLastWordFieldKey],
      isGunfight: map[FirestoreKeys.speakPhaseIsGunfightFieldKey],
      isBestMove: map[FirestoreKeys.speakPhaseIsBestMoveFieldKey],
      bestMove: bestMove,
    )..updatedAt = DateTime.fromMillisecondsSinceEpoch(
        map[FirestoreKeys.updatedAtFieldKey] ?? 0);
  }

  @override
  Map<String, dynamic> toFirestoreMap() {
    return super.toFirestoreMap()
      ..addAll(
        {
          FirestoreKeys.speakPhasePlayerTempIdFieldKey: playerTempId,
          FirestoreKeys.speakPhaseIsLastWordFieldKey: isLastWord,
          FirestoreKeys.speakPhaseIsGunfightFieldKey: isGunfight,
          FirestoreKeys.speakPhaseIsBestMoveFieldKey: isBestMove,
          FirestoreKeys.speakPhaseBestMoveTempIdsFieldKey: bestMove.map(
            (player) => player.tempId,
          ),
        },
      );
  }

  @override
  String toString() {
    return 'SpeakPhaseAction:'
        '\nplayerId: $playerTempId'
        '\ntimeForSpeakInSec: $timeForSpeakInSec'
        '\status: ${status.name}';
  }
}
