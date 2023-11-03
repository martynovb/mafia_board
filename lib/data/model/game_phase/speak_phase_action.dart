import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/phase_status.dart';

class SpeakPhaseAction extends GamePhaseAction {
  final String? playerId;
  Duration timeForSpeakInSec;
  bool isLastWord = false;
  bool isGunfight = false;

  SpeakPhaseAction({
    required int currentDay,
    required this.playerId,
    this.timeForSpeakInSec = Constants.defaultTimeForSpeak,
    this.isLastWord = false,
    PhaseStatus status = PhaseStatus.notStarted,
    this.isGunfight = false,
  }) : super(currentDay: currentDay, status: status);

  @override
  String toString() {
    return 'SpeakPhaseAction:'
        '\nplayerId: $playerId'
        '\ntimeForSpeakInSec: $timeForSpeakInSec'
        '\status: ${status.name}';
  }
}
