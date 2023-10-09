import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/phase_status.dart';

class SpeakPhaseAction extends GamePhaseAction {
  final PlayerModel? player;
  Duration timeForSpeakInSec;

  PhaseStatus status;
  bool isLastWord = false;

  SpeakPhaseAction({
    required int currentDay,
    required this.player,
    this.timeForSpeakInSec = const Duration(seconds: 59),
    this.isLastWord = false,
    this.status = PhaseStatus.notStarted,
  }) : super(currentDay);

  set updateStatus(PhaseStatus status) => this.status = status;

  SpeakPhaseAction.empty()
      : player = null,
        timeForSpeakInSec = const Duration(seconds: 60),
        status = PhaseStatus.notStarted,
        super(-1);

  @override
  String toString() {
    return 'SpeakPhaseAction:'
        '\nplayer: $player'
        '\ntimeForSpeakInSec: $timeForSpeakInSec'
        '\status: ${status.name}';
  }
}
