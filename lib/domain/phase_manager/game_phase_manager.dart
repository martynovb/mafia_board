import 'dart:async';

import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/data/repo/game_info/day_info_repo.dart';
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

  final DayInfoRepo dayInfoRepo;
  final PlayersRepo boardRepository;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final GamePhaseRepo<VotePhaseAction> voteGamePhaseRepo;
  final GamePhaseRepo<NightPhaseAction> nightGamePhaseRepo;
  final GameHistoryManager gameHistoryManager;
  final VotePhaseManager votePhaseGameManager;
  final SpeakingPhaseManager speakingPhaseManager;
  final NightPhaseManager nightPhaseManager;
  final PlayerManager playerManager;
  final BehaviorSubject<DayInfoModel> _dayInfoSubject = BehaviorSubject();

  GameManager({
    required this.boardRepository,
    required this.dayInfoRepo,
    required this.gameHistoryManager,
    required this.votePhaseGameManager,
    required this.voteGamePhaseRepo,
    required this.speakingPhaseManager,
    required this.speakGamePhaseRepo,
    required this.nightPhaseManager,
    required this.nightGamePhaseRepo,
    required this.playerManager,
  });

  Stream<DayInfoModel> get dayInfoStream => _dayInfoSubject.stream;

  Future<DayInfoModel?> get dayInfo => _dayInfoSubject.hasValue
      ? Future.value(_dayInfoSubject.value)
      : Future.value(null);

  Future<void> _updateDayInfo(DayInfoModel dayInfoModel) async {
    await dayInfoRepo.updateDayInfo(dayInfoModel);
    _dayInfoSubject.add(dayInfoModel);
  }

  Future<void> _resetData() async {
    await dayInfoRepo.deleteAll();
    boardRepository.deleteAll();
    speakGamePhaseRepo.deleteAll();
    voteGamePhaseRepo.deleteAll();
    nightGamePhaseRepo.deleteAll();
  }

  Future<DayInfoModel> startGame() async {
    await _resetData();
    const startDay = 1;
    final startDayInfoModel = DayInfoModel(
      day: startDay,
      isGameStarted: true,
      currentPhase: PhaseType.speak,
    );
    await speakingPhaseManager.preparedSpeakPhases(startDay);
    await dayInfoRepo.add(startDayInfoModel);
    _updateDayInfo(startDayInfoModel);
    gameHistoryManager.logGameStart(dayInfo: startDayInfoModel);
    gameHistoryManager.logNewDay(startDay);
    return startDayInfoModel;
  }

  Future<DayInfoModel?> nextGamePhase() async {
    if (await _isGameFinished()) {
      return await finishGame(FinishGameType.normalFinish);
    }

    final dayInfo = (await dayInfoRepo.getLastValidDayInfoByDay())!;

    final currentDay = dayInfo.day;

    if (!speakGamePhaseRepo.isExist(day: currentDay)) {
      await speakingPhaseManager.preparedSpeakPhases(currentDay);
    }

    if (!speakGamePhaseRepo.isFinished(day: currentDay)) {
      if (dayInfo.currentPhase != PhaseType.speak) {
        dayInfo.currentPhase = PhaseType.speak;
        _updateDayInfo(dayInfo);
      }
      MafLogger.d(_tag, 'Current phase: ${dayInfo.currentPhase}');
      return dayInfo;
    }

    await votePhaseGameManager.skipVotePhasesIfPossible();
    if (!voteGamePhaseRepo.isFinished(day: currentDay)) {
      if (dayInfo.currentPhase != PhaseType.vote) {
        dayInfo.currentPhase = PhaseType.vote;
        _updateDayInfo(dayInfo);
      }
      MafLogger.d(_tag, 'Current phase: ${dayInfo.currentPhase}');
      return dayInfo;
    }

    if (!nightGamePhaseRepo.isExist(day: currentDay)) {
      await nightPhaseManager.preparedNightPhases(currentDay);
    }

    if (!nightGamePhaseRepo.isFinished(day: currentDay)) {
      if (dayInfo.currentPhase != PhaseType.night) {
        dayInfo.currentPhase = PhaseType.night;
        _updateDayInfo(dayInfo);
      }
      MafLogger.d(_tag, 'Current phase: ${dayInfo.currentPhase}');
      return dayInfo;
    }

    return await _goNextDay(currentDay);
  }

  Future<DayInfoModel?> finishGame(FinishGameType finishGameType) async {
    final dayInfo = await dayInfoRepo.getLastValidDayInfoByDay();
    if (dayInfo == null) {
      return null;
    }

    dayInfo.isGameStarted = false;
    _updateDayInfo(dayInfo);
    gameHistoryManager.logGameFinish(dayInfo: dayInfo);
    return dayInfo;
  }

  Future<bool> _isGameFinished() async {
    final dayInfo = await dayInfoRepo.getLastValidDayInfoByDay();
    if (dayInfo == null || !dayInfo.isGameStarted) {
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

    if (!speakGamePhaseRepo.isFinished(day: dayInfo.day) || !nightGamePhaseRepo.isFinished(day: dayInfo.day)) {
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

  Future<DayInfoModel?> _goNextDay(int currentDay) async {
    MafLogger.d(_tag, 'Go to nex day');
    final nextDay = currentDay + 1;
    final lastDayInfo = await dayInfoRepo.getLastDayInfoByDay();
    final DayInfoModel nextDayInfoModel;

    if (lastDayInfo != null && lastDayInfo.day != currentDay) {
      nextDayInfoModel = lastDayInfo;
      nextDayInfoModel.currentPhase = PhaseType.speak;
      await dayInfoRepo.updateDayInfo(nextDayInfoModel);
    } else {
      nextDayInfoModel = DayInfoModel(
        day: nextDay,
        currentPhase: PhaseType.speak,
      );
      await dayInfoRepo.add(nextDayInfoModel);
    }
    await playerManager.refreshMuteIfNeeded(nextDayInfoModel);
    gameHistoryManager.logNewDay(nextDay);
    _updateDayInfo(nextDayInfoModel);

    return await nextGamePhase();
  }
}
