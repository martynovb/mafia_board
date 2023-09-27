import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';

class NightPhaseAction extends GamePhaseAction {
  final PlayerModel playerForWakeUp;
  final double timeInSec;
  bool isFinished = false;

  NightPhaseAction({
    required int currentDay,
    required this.playerForWakeUp,
    this.timeInSec = 10,
  }) : super(currentDay);
}
