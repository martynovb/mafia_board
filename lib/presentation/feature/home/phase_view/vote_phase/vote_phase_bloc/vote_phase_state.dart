import 'package:mafia_board/data/model/player_model.dart';

class VotePhaseState {
  final String title;
  final String playersToKickText;
  final PlayerModel? playerOnVote;
  final Map<PlayerModel, bool> allAvailablePlayersToVote;

  VotePhaseState({
    this.title = '',
    this.playersToKickText = '',
    this.playerOnVote,
    this.allAvailablePlayersToVote = const {},
  });
}
