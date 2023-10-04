import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';

class VotePhaseAction extends GamePhaseAction {
  final PlayerModel playerOnVote;
  final PlayerModel? whoPutOnVote;
  Set<PlayerModel> votedPlayers = {};
  bool isVoted;
  bool isGunfight;

  VotePhaseAction({
    required int currentDay,
    required this.playerOnVote,
    this.whoPutOnVote,
    this.isVoted = false,
    this.isGunfight = false,
  }) : super(currentDay);

  bool vote(PlayerModel playerModel) => votedPlayers.add(playerModel);

  void voteList(List<PlayerModel> list) => votedPlayers.addAll(list);

  bool removeVote(PlayerModel playerModel) => votedPlayers.remove(playerModel);



  @override
  String toString() {
    return 'VotePhaseAction: '
        '\nplayerOnVote: ${playerOnVote.toString()}'
        '\nwhoPutOnVote: ${whoPutOnVote.toString()}'
        '\nisVoted: $isVoted';
  }
}
