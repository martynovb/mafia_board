import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';

class SpeakPhaseAction extends GamePhaseAction {
  final PlayerModel? player;
  final double timeForSpeakInSec;
  bool isFinished = false;

  SpeakPhaseAction({
    required int currentDay,
    required this.player,
    this.timeForSpeakInSec = 60,
  }): super(currentDay);
}
