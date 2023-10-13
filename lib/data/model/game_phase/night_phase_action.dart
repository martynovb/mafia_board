import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/model/phase_status.dart';

class NightPhaseAction extends GamePhaseAction {
  final Role role;
  final List<PlayerModel> playersForWakeUp;
  final Duration timeForNight;
  PlayerModel? killedPlayer;
  PlayerModel? checkedPlayer;

  NightPhaseAction({
    required int currentDay,
    required this.role,
    this.playersForWakeUp = const [],
    this.timeForNight = const Duration(seconds: 10),
    PhaseStatus status = PhaseStatus.notStarted,
    this.killedPlayer,
    this.checkedPlayer,
  }) : super(currentDay: currentDay, status: status);
}
