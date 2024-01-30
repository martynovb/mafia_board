import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/usecase/create_day_info_usecase.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';
import 'package:mafia_board/domain/usecase/update_day_info_usecase.dart';

class PlayerManager {
  final PlayersRepo boardRepo;
  final GetCurrentGameUseCase getCurrentGameUseCase;
  final UpdateDayInfoUseCase updateDayInfoUseCase;
  final CreateDayInfoUseCase createDayInfoUseCase;
  final GamePhaseRepo<VotePhaseModel> voteGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;

  PlayerManager({
    required this.boardRepo,
    required this.voteGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.getCurrentGameUseCase,
    required this.updateDayInfoUseCase,
    required this.createDayInfoUseCase,
  });

  Future<void> refreshMuteIfNeeded(DayInfoModel dayInfo) async {
    final allActivePlayers = boardRepo.getAllAvailablePlayers();
    final mutedPlayerIds = dayInfo.getMutedPlayers.map((p) => p.tempId).toSet();

    for (PlayerModel player in allActivePlayers) {
      bool muted = mutedPlayerIds.contains(player.tempId);
      boardRepo.updatePlayer(
        player.tempId,
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

    final game = await getCurrentGameUseCase.execute();
    final dayInfo = game.currentDayInfo;

    if (player.fouls == Constants.maxFoulsToSpeak) {
      dayInfo.removedMutedPlayer(id);
    } else {
      dayInfo.removedMutedPlayer(id);
      dayInfo.removedRemovedPlayer(id);

      final speakPhases = speakGamePhaseRepo.getAllPhases();
      List<SpeakPhaseModel> todayAndFutureSpeakPhases = speakPhases
          .where((phase) =>
              phase.currentDay >= dayInfo.day && phase.playerTempId == player.tempId)
          .toList();
      for (var speakPhase in todayAndFutureSpeakPhases) {
        speakPhase.status = PhaseStatus.notStarted;
        speakGamePhaseRepo.update(gamePhase: speakPhase);
      }

      final votePhases = voteGamePhaseRepo.getAllPhases();
      List<VotePhaseModel> todayAndFutureVotePhases = votePhases
          .where((phase) =>
              phase.currentDay >= dayInfo.day &&
              phase.playerOnVote.tempId == player.tempId)
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

    final game = await getCurrentGameUseCase.execute();
    final dayInfo = game.currentDayInfo;
    final speakPhases = speakGamePhaseRepo.getAllPhasesByDay(day: dayInfo.day);

    if (isPlayerHasAlreadySpokenToday(speakPhases, id)) {
      //add mute for the next day
      await createDayInfoUseCase.execute(
          params: CreateDayInfoParams(
        day: dayInfo.day + 1,
        mutedPlayers: [player],
      ));
    } else {
      dayInfo.addMutedPlayer(player);
      await updateDayInfoUseCase.execute(params: dayInfo);
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

    final game = await getCurrentGameUseCase.execute();
    final dayInfo = game.currentDayInfo;

    //finish future speak phases
    final speakPhases = speakGamePhaseRepo.getAllPhases();
    List<SpeakPhaseModel> todayAndFutureSpeakPhases = speakPhases
        .where((phase) =>
            phase.currentDay >= dayInfo.day && phase.playerTempId == player.tempId)
        .toList();
    for (var speakPhase in todayAndFutureSpeakPhases) {
      if (speakPhase.status != PhaseStatus.finished) {
        speakPhase.status = PhaseStatus.finished;
        speakGamePhaseRepo.update(gamePhase: speakPhase);
      }
    }

    //finish future vote phases
    final votePhases = voteGamePhaseRepo.getAllPhases();
    List<VotePhaseModel> todayAndFutureVotePhases = votePhases
        .where((phase) =>
            phase.currentDay >= dayInfo.day &&
            phase.playerOnVote.tempId == player.tempId)
        .toList();
    for (var votePhase in todayAndFutureVotePhases) {
      if (votePhase.status != PhaseStatus.finished) {
        votePhase.status = PhaseStatus.finished;
        voteGamePhaseRepo.update(gamePhase: votePhase);
      }
    }

    dayInfo.removedMutedPlayer(id);
    dayInfo.addRemovedPlayer(player);
    await updateDayInfoUseCase.execute(params: dayInfo);
  }

  bool isPlayerHasAlreadySpokenToday(
      List<SpeakPhaseModel> speakPhases, String playerId) {
    return !speakPhases.any(
      (phase) =>
          phase.status != PhaseStatus.finished && phase.playerTempId == playerId,
    );
  }
}
