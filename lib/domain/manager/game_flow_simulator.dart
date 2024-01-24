import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/manager/game_flow/game_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/speaking_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/vote_phase_manager.dart';
import 'package:mafia_board/domain/model/role.dart';

class GameFlowSimulator {
  final GameManager gameManager;

  final PlayersRepo playersRepo;
  final SpeakingPhaseManager speakingPhaseManager;
  final VotePhaseManager votePhaseManager;

  GameFlowSimulator({
    required this.gameManager,
    required this.playersRepo,
    required this.speakingPhaseManager,
    required this.votePhaseManager,
  });

  Future<void> simulateFastGameCivilWin() async {
    //first day
    var allPlayers = playersRepo.getAllPlayers();

    allPlayers[0] = allPlayers[0]..role = Role.don;
    allPlayers[1] = allPlayers[1]..role = Role.mafia;
    allPlayers[2] = allPlayers[2]..role = Role.mafia;
    allPlayers[3] = allPlayers[3]..role = Role.sheriff;
    allPlayers[4] = allPlayers[4]..role = Role.civilian;
    allPlayers[5] = allPlayers[5]..role = Role.civilian;
    allPlayers[6] = allPlayers[6]..role = Role.civilian;
    allPlayers[7] = allPlayers[7]..role = Role.civilian;
    allPlayers[8] = allPlayers[8]..role = Role.civilian;
    allPlayers[9] = allPlayers[9]..role = Role.civilian;

    for (var i = 0; i < allPlayers.length; i++) {
      if (i < 5) {
        await speakingPhaseManager.startSpeech();
        await Future.delayed(const Duration(seconds: 1));
        await votePhaseManager.putOnVote(allPlayers[i].id);
        await speakingPhaseManager.finishSpeech();
      } else {
        await speakingPhaseManager.startSpeech();
        await Future.delayed(const Duration(seconds: 1));
        await speakingPhaseManager.finishSpeech();
      }
      await gameManager.nextGamePhase();
    }

    var votePhases = await votePhaseManager.getAllTodaysPhases();

    //vote against 1 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[0],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[1],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    //vote against 2 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[2],
      voteAgainstPlayer: votePhases[1].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[3],
      voteAgainstPlayer: votePhases[1].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    //vote against 3 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[4],
      voteAgainstPlayer: votePhases[2].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[5],
      voteAgainstPlayer: votePhases[2].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    //vote against 4 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[6],
      voteAgainstPlayer: votePhases[3].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[7],
      voteAgainstPlayer: votePhases[3].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    for (var i = 0; i < 5; i++) {
      await speakingPhaseManager.startSpeech();
      await Future.delayed(const Duration(seconds: 1));
      await speakingPhaseManager.finishSpeech();
      await gameManager.nextGamePhase();
    }

    //REVOTE

    //vote against 1 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[0],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[1],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    //vote against 2 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[2],
      voteAgainstPlayer: votePhases[1].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[3],
      voteAgainstPlayer: votePhases[1].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    //vote against 3 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[4],
      voteAgainstPlayer: votePhases[2].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[5],
      voteAgainstPlayer: votePhases[2].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    //vote against 4 player
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[6],
      voteAgainstPlayer: votePhases[3].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[7],
      voteAgainstPlayer: votePhases[3].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    //kick all
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[0],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[1],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[2],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[3],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[4],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.voteAgainst(
      currentPlayer: allPlayers[5],
      voteAgainstPlayer: votePhases[0].playerOnVote,
    );
    await votePhaseManager.finishCurrentVotePhase();
    await gameManager.nextGamePhase();

    for (var i = 0; i < 5; i++) {
      await speakingPhaseManager.startSpeech();
      await Future.delayed(const Duration(seconds: 1));
      await speakingPhaseManager.finishSpeech();
      await gameManager.nextGamePhase();
    }
  }
}
