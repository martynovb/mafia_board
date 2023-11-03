import 'dart:async';

import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/night_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/domain/player_manager.dart';
import 'package:mafia_board/presentation/maf_logger.dart';
import 'package:rxdart/rxdart.dart';

class GameManager {
  static const _tag = 'GameManager';

  final GameInfoRepo gameInfoRepo;
  final PlayersRepo boardRepository;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final GamePhaseRepo<VotePhaseAction> voteGamePhaseRepo;
  final GamePhaseRepo<NightPhaseAction> nightGamePhaseRepo;
  final GameHistoryManager gameHistoryManager;
  final VotePhaseManager votePhaseGameManager;
  final SpeakingPhaseManager speakingPhaseManager;
  final NightPhaseManager nightPhaseManager;
  final PlayerManager playerManager;
  final BehaviorSubject<GameInfoModel> _gameInfoSubject = BehaviorSubject();

  GameManager({
    required this.boardRepository,
    required this.gameInfoRepo,
    required this.gameHistoryManager,
    required this.votePhaseGameManager,
    required this.voteGamePhaseRepo,
    required this.speakingPhaseManager,
    required this.speakGamePhaseRepo,
    required this.nightPhaseManager,
    required this.nightGamePhaseRepo,
    required this.playerManager,
  });

  Stream<GameInfoModel> get gameInfoStream => _gameInfoSubject.stream;

  Future<GameInfoModel?> get gameInfo => _gameInfoSubject.hasValue
      ? Future.value(_gameInfoSubject.value)
      : Future.value(null);

  Future<void> _updateGameInfo(GameInfoModel gameInfoModel) async {
    await gameInfoRepo.updateGameInfo(gameInfoModel);
    _gameInfoSubject.add(gameInfoModel);
  }

  Future<void> _resetData() async {
    await gameInfoRepo.deleteAll();
    boardRepository.deleteAll();
    speakGamePhaseRepo.deleteAll();
    voteGamePhaseRepo.deleteAll();
    nightGamePhaseRepo.deleteAll();
  }

  Future<GameInfoModel> startGame() async {
    await _resetData();
    const startDay = 1;
    final startGameInfoModel = GameInfoModel(
      day: startDay,
      isGameStarted: true,
      currentPhase: PhaseType.speak,
    );
    await speakingPhaseManager.preparedSpeakPhases(startDay);
    await gameInfoRepo.add(startGameInfoModel);
    _updateGameInfo(startGameInfoModel);
    gameHistoryManager.logGameStart(gameInfo: startGameInfoModel);
    gameHistoryManager.logNewDay(startDay);
    return startGameInfoModel;
  }

  Future<GameInfoModel?> nextGamePhase() async {
    if (await _isGameFinished()) {
      return await finishGame();
    }

    final gameInfo = (await gameInfoRepo.getLastValidGameInfoByDay())!;

    final currentDay = gameInfo.day;

    if (!speakGamePhaseRepo.isExist(day: currentDay)) {
      await speakingPhaseManager.preparedSpeakPhases(currentDay);
    }

    if (!speakGamePhaseRepo.isFinished(day: currentDay)) {
      if (gameInfo.currentPhase != PhaseType.speak) {
        gameInfo.currentPhase = PhaseType.speak;
        _updateGameInfo(gameInfo);
      }
      MafLogger.d(_tag, 'Current phase: ${gameInfo.currentPhase}');
      return gameInfo;
    }

    await votePhaseGameManager.skipVotePhasesIfPossible();
    if (!voteGamePhaseRepo.isFinished(day: currentDay)) {
      if (gameInfo.currentPhase != PhaseType.vote) {
        gameInfo.currentPhase = PhaseType.vote;
        _updateGameInfo(gameInfo);
      }
      MafLogger.d(_tag, 'Current phase: ${gameInfo.currentPhase}');
      return gameInfo;
    }

    if (!nightGamePhaseRepo.isExist(day: currentDay)) {
      await nightPhaseManager.preparedNightPhases(currentDay);
    }

    if (!nightGamePhaseRepo.isFinished(day: currentDay)) {
      if (gameInfo.currentPhase != PhaseType.night) {
        gameInfo.currentPhase = PhaseType.night;
        _updateGameInfo(gameInfo);
      }
      MafLogger.d(_tag, 'Current phase: ${gameInfo.currentPhase}');
      return gameInfo;
    }

    return await _goNextDay(currentDay);
  }

  Future<GameInfoModel?> finishGame() async {
    final gameInfo = await gameInfoRepo.getLastValidGameInfoByDay();
    if (gameInfo == null) {
      return null;
    }

    gameInfo.isGameStarted = false;
    _updateGameInfo(gameInfo);
    gameHistoryManager.logGameFinish(gameInfo: gameInfo);
    return gameInfo;
  }

  Future<bool> _isGameFinished() async {
    final gameInfo = await gameInfoRepo.getLastValidGameInfoByDay();
    if (gameInfo == null || !gameInfo.isGameStarted) {
      return true;
    }
    final allPlayers = boardRepository.getAllAvailablePlayers();
    int mafsCount = allPlayers
        .where((player) => player.role == Role.MAFIA || player.role == Role.DON)
        .length;

    int civilianCount = allPlayers
        .where(
          (player) =>
              player.role == Role.CIVILIAN ||
              player.role == Role.SHERIFF ||
              player.role == Role.DOCTOR ||
              player.role == Role.PUTANA ||
              player.role == Role.MANIAC,
        )
        .length;

    if (!speakGamePhaseRepo.isFinished(day: gameInfo.day) || !nightGamePhaseRepo.isFinished(day: gameInfo.day)) {
      return false;
    }

    if (mafsCount >= civilianCount) {
      return true;
    }

    if (mafsCount <= 0) {
      return true;
    }

    return false;
  }

  Future<GameInfoModel?> _goNextDay(int currentDay) async {
    MafLogger.d(_tag, 'Go to nex day');
    final nextDay = currentDay + 1;
    final lastGameInfo = await gameInfoRepo.getLastGameInfoByDay();
    final GameInfoModel nextGameInfoModel;

    if (lastGameInfo != null && lastGameInfo.day != currentDay) {
      nextGameInfoModel = lastGameInfo;
      nextGameInfoModel.currentPhase = PhaseType.speak;
      await gameInfoRepo.updateGameInfo(nextGameInfoModel);
    } else {
      nextGameInfoModel = GameInfoModel(
        day: nextDay,
        currentPhase: PhaseType.speak,
      );
      await gameInfoRepo.add(nextGameInfoModel);
    }
    await playerManager.refreshMuteIfNeeded(nextGameInfoModel);
    gameHistoryManager.logNewDay(nextDay);
    _updateGameInfo(nextGameInfoModel);

    return await nextGamePhase();
  }
}
