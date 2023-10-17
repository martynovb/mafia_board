import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo_local.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class VotePhaseRepoLocal extends BasePhaseRepoLocal<VotePhaseAction> {

  @override
  List<VotePhaseAction> getAllPhasesByDay({int? day}) {
    List<VotePhaseAction> todaysPhases = super.getAllPhasesByDay(day: day);
    List<VotePhaseAction> votePhases = [];
    List<VotePhaseAction> gunfightVotePhases = [];
    VotePhaseAction? askToKickAllPlayers;
    final seenIds = <int>{};
    for (var votePhase in todaysPhases) {
      final hashCode = votePhase.hashCode;
      if (seenIds.add(hashCode)) {
        if (votePhase.shouldKickAllPlayers) {
          askToKickAllPlayers = votePhase;
        }
        if (votePhase.isGunfight) {
          gunfightVotePhases.add(votePhase);
        } else {
          votePhases.add(votePhase);
        }
      }
    }

    if (askToKickAllPlayers != null) {
      return [askToKickAllPlayers];
    } else if (gunfightVotePhases.isNotEmpty) {
      return gunfightVotePhases;
    }

    MafLogger.d('VotePhaseRepoLocal', votePhases.toString());

    return votePhases;
  }
}
