import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo.dart';

class VotePhaseRepo extends BasePhaseRepo<VotePhaseModel> {
  VotePhaseRepo({required super.firestore});

  @override
  List<VotePhaseModel> getAllPhasesByDay({required int day}) {
    List<VotePhaseModel> todaysPhases = super.getAllPhasesByDay(day: day);
    List<VotePhaseModel> votePhases = [];
    List<VotePhaseModel> gunfightVotePhases = [];
    VotePhaseModel? askToKickAllPlayers;
    final seenIds = <int>{};
    for (var votePhase in todaysPhases) {
      final hashCode = votePhase.hashCode;
      if (seenIds.add(hashCode)) {
        if (votePhase.shouldKickAllPlayers) {
          askToKickAllPlayers = votePhase;
          break;
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

    return votePhases;
  }
}
