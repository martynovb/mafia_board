import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class VotePhaseState {
  final PhaseStatus phaseStatus;
  final VotePhaseModel? votePhase;
  final Map<PlayerModel, bool> allAvailablePlayersToVote;
  final List<PlayerModel> players;

  VotePhaseState({
    required this.phaseStatus,
    this.votePhase,
    this.allAvailablePlayersToVote = const {},
    required this.players,
  });
}
