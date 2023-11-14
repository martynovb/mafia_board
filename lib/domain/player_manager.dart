import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/game_info/day_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';

class PlayerManager {
  final PlayersRepo boardRepo;
  final DayInfoRepo dayInfoRepo;
  final GamePhaseRepo<VotePhaseAction> voteGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;

  PlayerManager({
    required this.boardRepo,
    required this.voteGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.dayInfoRepo,
  });

  Future<void> refreshMuteIfNeeded(DayInfoModel dayInfo) async {
    final allActivePlayers = boardRepo.getAllAvailablePlayers();
    final mutedPlayerIds = dayInfo.mutedPlayers.map((p) => p.id).toSet();

    for (PlayerModel player in allActivePlayers) {
      bool muted = mutedPlayerIds.contains(player.id);
      boardRepo.updatePlayer(
        player.id,
        isMuted: muted,
      );
    }
  }

  Future<void> addFoul(String id, int newFoulsCount) async {
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

  Future<void> clearFouls(String id) async {
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

    final dayInfo = (await dayInfoRepo.getLastValidDayInfoByDay())!;

    if (player.fouls == Constants.maxFoulsToSpeak) {
      dayInfo.removedMutedPlayer(id);
    } else {
      dayInfo.removedMutedPlayer(id);
      dayInfo.removedRemovedPlayer(id);

      final speakPhases = speakGamePhaseRepo.getAllPhases();
      List<SpeakPhaseAction> todayAndFutureSpeakPhases = speakPhases
          .where((phase) =>
              phase.currentDay >= dayInfo.day && phase.playerId == player.id)
          .toList();
      for (var speakPhase in todayAndFutureSpeakPhases) {
        speakPhase.status = PhaseStatus.notStarted;
        speakGamePhaseRepo.update(gamePhase: speakPhase);
      }

      final votePhases = voteGamePhaseRepo.getAllPhases();
      List<VotePhaseAction> todayAndFutureVotePhases = votePhases
          .where((phase) =>
              phase.currentDay >= dayInfo.day &&
              phase.playerOnVote.id == player.id)
          .toList();
      for (var votePhase in todayAndFutureVotePhases) {
        votePhase.status = PhaseStatus.notStarted;
        voteGamePhaseRepo.update(gamePhase: votePhase);
      }
    }
  }

  Future<void> _mutePlayer(String id) async {
    final player = await boardRepo.getPlayerById(id);
    if (player == null) {
      return;
    }

    await boardRepo.updatePlayer(
      id,
      isMuted: true,
      fouls: Constants.maxFoulsToSpeak,
    );

    final dayInfo = (await dayInfoRepo.getLastValidDayInfoByDay())!;
    final speakPhases = speakGamePhaseRepo.getAllPhasesByDay(day: dayInfo.day);

    if (isPlayerHasAlreadySpokenToday(speakPhases, id)) {
      //add mute for the next day
      await dayInfoRepo.add(
        DayInfoModel(day: dayInfo.day + 1)..addMutedPlayer(player),
      );
    } else {
      dayInfo.addMutedPlayer(player);
      await dayInfoRepo.updateDayInfo(dayInfo);
    }
  }

  Future<void> _removePlayer(String id) async {
    final player = await boardRepo.getPlayerById(id);
    if (player == null) {
      return;
    }

    await boardRepo.updatePlayer(
      id,
      isRemoved: true,
      fouls: Constants.maxFouls,
    );

    final dayInfo = (await dayInfoRepo.getLastValidDayInfoByDay())!;

    //finish future speak phases
    final speakPhases = speakGamePhaseRepo.getAllPhases();
    List<SpeakPhaseAction> todayAndFutureSpeakPhases = speakPhases
        .where((phase) =>
            phase.currentDay >= dayInfo.day && phase.playerId == player.id)
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
            phase.currentDay >= dayInfo.day &&
            phase.playerOnVote.id == player.id)
        .toList();
    for (var votePhase in todayAndFutureVotePhases) {
      if (votePhase.status != PhaseStatus.finished) {
        votePhase.status = PhaseStatus.finished;
        voteGamePhaseRepo.update(gamePhase: votePhase);
      }
    }

    dayInfo.removedMutedPlayer(id);
    dayInfo.addRemovedPlayer(player);
    dayInfoRepo.updateDayInfo(dayInfo);
  }

  bool isPlayerHasAlreadySpokenToday(
      List<SpeakPhaseAction> speakPhases, String playerId) {
    return !speakPhases.any(
      (phase) =>
          phase.status != PhaseStatus.finished && phase.playerId == playerId,
    );
  }
}
