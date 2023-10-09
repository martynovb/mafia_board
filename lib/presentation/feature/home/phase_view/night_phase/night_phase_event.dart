import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';

abstract class NightPhaseEvent {
  final Role role;

  NightPhaseEvent({this.role = Role.NONE});
}

class GetCurrentNightPhaseEvent extends NightPhaseEvent {}

class FinishCurrentNightPhaseEvent extends NightPhaseEvent {}

class StartCurrentNightPhaseEvent extends NightPhaseEvent {}

class KillEvent extends NightPhaseEvent {
  final PlayerModel killedPlayer;

  KillEvent({
    required Role role,
    required this.killedPlayer,
  }) : super(role: role);
}

class CheckEvent extends NightPhaseEvent {
  final PlayerModel playerToCheck;

  CheckEvent({
    required Role role,
    required this.playerToCheck,
  }) : super(role: role);
}

class VisitEvent extends NightPhaseEvent {
  final PlayerModel playerToVisit;

  VisitEvent({
    required Role role,
    required this.playerToVisit,
  }) : super(role: role);
}
