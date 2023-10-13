import 'dart:async';

import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/night_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:rxdart/rxdart.dart';

class GameManager {
  static const _tag = 'GameManager';

  final GameInfoRepo gameInfoRepo;
  final BoardRepo boardRepository;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final GamePhaseRepo<VotePhaseAction> voteGamePhaseRepo;
  final GamePhaseRepo<NightPhaseAction> nightGamePhaseRepo;
  final GameHistoryManager gameHistoryManager;
  final VotePhaseManager votePhaseGameManager;
  final SpeakingPhaseManager speakingPhaseManager;
  final NightPhaseManager nightPhaseManager;
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
  });

  Stream<GameInfoModel> get gameInfoStream => _gameInfoSubject.stream;

  Future<GameInfoModel?> get gameInfo => _gameInfoSubject.hasValue
      ? Future.value(_gameInfoSubject.value)
      : Future.value(null);

  void _updateGameInfo(GameInfoModel gameInfoModel) {
    gameInfoRepo.updateGameInfo(gameInfoModel);
    _gameInfoSubject.add(gameInfoModel);
  }

  void _resetData() {
    gameInfoRepo.deleteAll();
    boardRepository.deleteAll();
    speakGamePhaseRepo.deleteAll();
    voteGamePhaseRepo.deleteAll();
    nightGamePhaseRepo.deleteAll();
  }

  void startGame() {
    _resetData();
    const startDay = 1;
    final startGameInfoModel = GameInfoModel(day: startDay);
    gameInfoRepo.add(startGameInfoModel);
    speakingPhaseManager.preparedSpeakPhases(startDay);
    _updateGameInfo(startGameInfoModel);
    gameHistoryManager.logGameStart(gameInfo: startGameInfoModel);
    gameHistoryManager.logNewDay(startDay);
  }

  Future<void> nextGamePhase() async {
    if (await _isGameFinished()) {
      finishGame();
      return;
    }

    final gameInfo = (await gameInfoRepo.getLastGameInfoByDay())!;

    final currentDay = gameInfo.day;

    if (!speakGamePhaseRepo.isExist(day: currentDay)) {
      speakingPhaseManager.preparedSpeakPhases(currentDay);
    }

    if (!speakGamePhaseRepo.isFinished(day: currentDay)) {
      gameInfo.currentPhase = PhaseType.speak;
      _updateGameInfo(gameInfo);
      return;
    }

    votePhaseGameManager.skipVotePhasesIfPossible();
    if (!voteGamePhaseRepo.isFinished(day: currentDay)) {
      gameInfo.currentPhase = PhaseType.vote;
      _updateGameInfo(gameInfo);
      return;
    }

    if (!nightGamePhaseRepo.isExist(day: currentDay)) {
      nightPhaseManager.preparedNightPhases(currentDay);
    }

    if (!nightGamePhaseRepo.isFinished(day: currentDay)) {
      gameInfo.currentPhase = PhaseType.night;
      _updateGameInfo(gameInfo);
      return;
    }

    final nextDay = currentDay + 1;
    final nextGameInfoModel = GameInfoModel(day: nextDay);
    gameInfoRepo.add(nextGameInfoModel);
    gameHistoryManager.logNewDay(nextDay);

    nextGamePhase();
  }

  Future<void> finishGame() async {
    final gameInfo = await gameInfoRepo.getLastGameInfoByDay();
    if (gameInfo == null) {
      return;
    }

    gameInfo.isGameFinished = true;
    gameHistoryManager.logGameFinish(gameInfo: gameInfo);
  }

  Future<bool> _isGameFinished() async {
    final gameInfo = await gameInfoRepo.getLastGameInfoByDay();
    if (gameInfo == null || gameInfo.isGameFinished) {
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

    if (!speakGamePhaseRepo.isFinished()) {
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
}
