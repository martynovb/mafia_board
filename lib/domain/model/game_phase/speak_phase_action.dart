import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/domain/model/phase_status.dart';

class SpeakPhaseAction extends GamePhaseAction {
  final String? playerId;
  Duration timeForSpeakInSec;
  bool isLastWord;
  bool isGunfight;
  bool isBestMove;
  List<int> bestMove = [];

  SpeakPhaseAction({
    required int currentDay,
    required this.playerId,
    this.timeForSpeakInSec = Constants.defaultTimeForSpeak,
    PhaseStatus status = PhaseStatus.notStarted,
    this.isLastWord = false,
    this.isGunfight = false,
    this.isBestMove = false,
  }) : super(currentDay: currentDay, status: status);

  @override
  String toString() {
    return 'SpeakPhaseAction:'
        '\nplayerId: $playerId'
        '\ntimeForSpeakInSec: $timeForSpeakInSec'
        '\status: ${status.name}';
  }
}
