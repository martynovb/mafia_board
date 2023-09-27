import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';

class VotePhaseAction extends GamePhaseAction {
  final PlayerModel playerOnVote;
  final PlayerModel whoPutOnVote;
  Set<PlayerModel> votedPlayers = {};
  bool isVoted = false;

  VotePhaseAction({
    required int currentDay,
    required this.playerOnVote,
    required this.whoPutOnVote,
  }) : super(currentDay);

  void vote(PlayerModel playerModel){
    votedPlayers.add(playerModel);
  }
}
