import 'package:mafia_board/data/model/game_phase/game_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';

class VotePhaseAction extends GamePhaseAction {
  final PlayerModel playerOnVote;
  final PlayerModel? whoPutOnVote;
  final List<PlayerModel> playersToKick;
  Set<PlayerModel> votedPlayers = {};
  bool isGunfight;
  bool shouldKickAllPlayers;

  VotePhaseAction({
    required int currentDay,
    required this.playerOnVote,
    this.whoPutOnVote,
    this.isGunfight = false,
    this.shouldKickAllPlayers = false,
    this.playersToKick = const [],
  }) : super(currentDay: currentDay);

  bool vote(PlayerModel playerModel) => votedPlayers.add(playerModel);

  void addVoteList(List<PlayerModel> list) => votedPlayers.addAll(list);

  bool removeVote(PlayerModel playerModel) => votedPlayers.remove(playerModel);

  @override
  String toString() {
    return 'VotePhaseAction: '
        '\nplayerOnVote: ${playerOnVote.toString()}'
        '\nwhoPutOnVote: ${whoPutOnVote.toString()}';
  }
}
