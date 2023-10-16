import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/model/player_model.dart';

class VotePhaseState {
  final String title;
  final String playersToKickText;
  final PlayerModel? playerOnVote;
  final Map<PlayerModel, bool> allAvailablePlayersToVote;
  final PhaseStatus status;

  VotePhaseState({
    this.title = '',
    this.playersToKickText = '',
    this.playerOnVote,
    this.allAvailablePlayersToVote = const {},
    this.status = PhaseStatus.notStarted,
  });
}
