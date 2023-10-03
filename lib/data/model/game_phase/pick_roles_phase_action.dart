import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';

class PickRolePhaseAction extends GamePhaseAction {
  final List<PlayerModel> allPlayers;

  PickRolePhaseAction({
    required int currentDay,
    required this.allPlayers,
  }) : super(currentDay);
}
