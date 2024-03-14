import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class VotePhaseState {
  final String playersToKickText;
  final PlayerModel? playerOnVote;
  final Map<PlayerModel, bool> allAvailablePlayersToVote;
  final List<PlayerModel> players;
  final PhaseStatus status;

  VotePhaseState({
    this.playersToKickText = '',
    this.playerOnVote,
    this.allAvailablePlayersToVote = const {},
    required this.players,
    this.status = PhaseStatus.notStarted,
  });
}
