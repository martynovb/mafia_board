import 'package:mafia_board/data/model/player_model.dart';

class VotePhaseState {
  final PlayerModel? playerOnVote;
  final Map<PlayerModel, bool> allAvailablePlayersToVote;

  VotePhaseState({
    this.playerOnVote,
    this.allAvailablePlayersToVote = const {},
  });
}
