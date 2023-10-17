import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';

class PlayerManager {
  final BoardRepo boardRepo;
  final GameInfoRepo gameInfoRepo;
  final GamePhaseRepo<VotePhaseAction> voteGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;

  PlayerManager({
    required this.boardRepo,
    required this.voteGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.gameInfoRepo,
  });

  Future<void> addFoul(int id, int newFoulsCount) async {
    if (newFoulsCount == Constants.maxFouls) {
      await _removePlayer(id);
    } else if (newFoulsCount == Constants.maxFoulsToSpeak) {
      await _mutePlayer(id);
    }

    await boardRepo.updatePlayer(
      id,
      fouls: newFoulsCount,
    );
  }

  Future<void> clearFouls(int id) async {
    final player = await boardRepo.getPlayerById(id);
    if (player == null) {
      return;
    }

    await boardRepo.updatePlayer(
      id,
      isRemoved: false,
      isMuted: false,
      fouls: 0,
    );

    final gameInfo = (await gameInfoRepo.getLastValidGameInfoByDay())!;

    if (player.fouls == Constants.maxFoulsToSpeak) {
      gameInfo.removedMutedPlayer(id);
    } else {
      gameInfo.removedRemovedPlayer(id);

      final speakPhases = speakGamePhaseRepo.getAllPhases();
      List<SpeakPhaseAction> todayAndFutureSpeakPhases = speakPhases
          .where((phase) =>
              phase.currentDay >= gameInfo.day && phase.playerId == player.id)
          .toList();
      for (var speakPhase in todayAndFutureSpeakPhases) {
        speakPhase.status = PhaseStatus.notStarted;
        speakGamePhaseRepo.update(gamePhase: speakPhase);
      }

      final votePhases = voteGamePhaseRepo.getAllPhases();
      List<VotePhaseAction> todayAndFutureVotePhases = votePhases
          .where((phase) =>
              phase.currentDay >= gameInfo.day &&
              phase.playerOnVote.id == player.id)
          .toList();
      for (var votePhase in todayAndFutureVotePhases) {
        votePhase.status = PhaseStatus.notStarted;
        voteGamePhaseRepo.update(gamePhase: votePhase);
      }
    }
  }

  Future<void> _mutePlayer(int id) async {
    final player = await boardRepo.getPlayerById(id);
    if (player == null) {
      return;
    }

    await boardRepo.updatePlayer(
      id,
      isMuted: true,
      fouls: Constants.maxFoulsToSpeak,
    );

    final gameInfo = (await gameInfoRepo.getLastValidGameInfoByDay())!;
    final speakPhases = speakGamePhaseRepo.getAllPhasesByDay(day: gameInfo.day);

    if (isPlayerHasAlreadySpokenToday(speakPhases, id)) {
      //add mute for the next day
      await gameInfoRepo.add(
        GameInfoModel(day: gameInfo.day + 1)..addMutedPlayer(player),
      );
    } else {
      gameInfo.addMutedPlayer(player);
      await gameInfoRepo.updateGameInfo(gameInfo);
    }
  }

  Future<void> _removePlayer(int id) async {
    final player = await boardRepo.getPlayerById(id);
    if (player == null) {
      return;
    }

    await boardRepo.updatePlayer(
      id,
      isRemoved: true,
      fouls: Constants.maxFouls,
    );

    final gameInfo = (await gameInfoRepo.getLastValidGameInfoByDay())!;

    //finish future speak phases
    final speakPhases = speakGamePhaseRepo.getAllPhases();
    List<SpeakPhaseAction> todayAndFutureSpeakPhases = speakPhases
        .where((phase) =>
            phase.currentDay >= gameInfo.day && phase.playerId == player.id)
        .toList();
    for (var speakPhase in todayAndFutureSpeakPhases) {
      if (speakPhase.status != PhaseStatus.finished) {
        speakPhase.status = PhaseStatus.finished;
        speakGamePhaseRepo.update(gamePhase: speakPhase);
      }
    }

    //finish future vote phases
    final votePhases = voteGamePhaseRepo.getAllPhases();
    List<VotePhaseAction> todayAndFutureVotePhases = votePhases
        .where((phase) =>
            phase.currentDay >= gameInfo.day &&
            phase.playerOnVote.id == player.id)
        .toList();
    for (var votePhase in todayAndFutureVotePhases) {
      if (votePhase.status != PhaseStatus.finished) {
        votePhase.status = PhaseStatus.finished;
        voteGamePhaseRepo.update(gamePhase: votePhase);
      }
    }

    gameInfo.removedMutedPlayer(id);
    gameInfo.addRemovedPlayer(player);
    gameInfoRepo.updateGameInfo(gameInfo);
  }

  bool isPlayerHasAlreadySpokenToday(
      List<SpeakPhaseAction> speakPhases, int playerId) {
    return !speakPhases.any(
      (phase) =>
          phase.status != PhaseStatus.finished && phase.playerId == playerId,
    );
  }
}
