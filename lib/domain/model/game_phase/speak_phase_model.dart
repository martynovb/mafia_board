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
  List<PlayerModel> bestMove = [];

  SpeakPhaseModel({
    String? id,
    required int currentDay,
    required this.playerTempId,
    this.timeForSpeakInSec = Constants.defaultTimeForSpeak,
    PhaseStatus status = PhaseStatus.notStarted,
    this.isLastWord = false,
    this.isGunfight = false,
    this.isBestMove = false,
  }) : super(
          id: id,
          currentDay: currentDay,
          status: status,
        );

  @override
  PhaseType get phaseType => PhaseType.speak;

  @override
  Map<String, dynamic> toFirestoreMap() {
    return super.toFirestoreMap()
      ..addAll(
        {
          FirestoreKeys.speakPhasePlayerTempIdFieldKey: playerTempId,
          FirestoreKeys.speakPhaseIsLastWordFieldKey: isLastWord,
          FirestoreKeys.speakPhaseIsGunfightFieldKey: isGunfight,
          FirestoreKeys.speakPhaseIsBestMoveFieldKey: isBestMove,
          FirestoreKeys.speakPhaseBestMoveFieldKey: bestMove,
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
