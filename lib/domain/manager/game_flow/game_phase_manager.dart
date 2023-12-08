import 'dart:async';

import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/manager/game_history_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/night_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/speaking_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/vote_phase_manager.dart';
import 'package:mafia_board/domain/manager/player_manager.dart';
import 'package:mafia_board/domain/usecase/create_day_info_usecase.dart';
import 'package:mafia_board/domain/usecase/create_game_usecase.dart';
import 'package:mafia_board/domain/usecase/finish_game_usecase.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';
import 'package:mafia_board/domain/usecase/get_last_day_info_usecase.dart';
import 'package:mafia_board/domain/usecase/remove_game_data_usecase.dart';
import 'package:mafia_board/domain/usecase/update_day_info_usecase.dart';
import 'package:mafia_board/presentation/maf_logger.dart';
import 'package:rxdart/rxdart.dart';

class GameManager {
  static const _tag = 'GameManager';

  final GameRepo dayInfoRepo;
  final PlayersRepo playersRepository;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final GamePhaseRepo<VotePhaseAction> voteGamePhaseRepo;
  final GamePhaseRepo<NightPhaseAction> nightGamePhaseRepo;
  final GameHistoryManager gameHistoryManager;
  final VotePhaseManager votePhaseGameManager;
  final SpeakingPhaseManager speakingPhaseManager;
  final NightPhaseManager nightPhaseManager;
  final PlayerManager playerManager;

  final CreateDayInfoUseCase createDayInfoUseCase;
  final UpdateDayInfoUseCase updateDayInfoUseCase;

  final GetLastDayInfoUseCase getLastDayInfoUseCase;
  final CreateGameUseCase createGameUseCase;
  final GetCurrentGameUseCase getCurrentGameUseCase;
  final FinishGameUseCase finishGameUseCase;
  final RemoveGameDataUseCase removeGameDataUseCase;

  final BehaviorSubject<GameModel?> _gameSubject = BehaviorSubject();

  GameManager({
    required this.playersRepository,
    required this.dayInfoRepo,
    required this.gameHistoryManager,
    required this.votePhaseGameManager,
    required this.voteGamePhaseRepo,
    required this.speakingPhaseManager,
    required this.speakGamePhaseRepo,
    required this.nightPhaseManager,
    required this.nightGamePhaseRepo,
    required this.playerManager,
    required this.createDayInfoUseCase,
    required this.updateDayInfoUseCase,
    required this.createGameUseCase,
    required this.getCurrentGameUseCase,
    required this.getLastDayInfoUseCase,
    required this.finishGameUseCase,
    required this.removeGameDataUseCase,
  });

  Stream<GameModel?> get gameStream => _gameSubject.stream;

  Future<void> _updateDayInfo(DayInfoModel dayInfoModel) async {
    await updateDayInfoUseCase.execute(params: dayInfoModel);
    _gameSubject.add(await getCurrentGameUseCase.execute());
  }

  Future<void> startGame(String clubId) async {
    //create a game in specific club
    await createGameUseCase.execute(
      params: CreateGameParams(
        clubId: clubId,
        gameStatus: GameStatus.inProgress,
      ),
    );
    //create first day and set speak phase as initial game phase
    final firstDay = await createDayInfoUseCase.execute(
      params: CreateDayInfoParams(
          day: Constants.firstDay, initialGamePhase: PhaseType.speak),
    );
    await speakingPhaseManager.preparedSpeakPhases(firstDay.day);
    gameHistoryManager.logGameStart(dayInfo: firstDay);
    gameHistoryManager.logNewDay(firstDay.day);
  }

  Future<DayInfoModel> nextGamePhase() async {
    if (await _isGameFinished()) {
      return await finishGame(FinishGameType.normalFinish);
    }

    final game = await getCurrentGameUseCase.execute();

    final dayInfo = game.currentDayInfo;
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
    // workaround, refactor duplication of code
    if (!speakGamePhaseRepo.isFinished(day: currentDay)) {
      if (dayInfo.currentPhase != PhaseType.speak) {
        dayInfo.currentPhase = PhaseType.speak;
        _updateDayInfo(dayInfo);
      }
      MafLogger.d(_tag, 'Current phase: ${dayInfo.currentPhase}');
      return dayInfo;
    }

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

  Future<DayInfoModel> finishGame(FinishGameType finishGameType) async {
    final game = await finishGameUseCase.execute(params: finishGameType);
    final dayInfo = game.currentDayInfo;

    _updateDayInfo(dayInfo);
    gameHistoryManager.logGameFinish(dayInfo: dayInfo);
    return dayInfo;
  }

  Future<bool> _isGameFinished() async {
    final game = await getCurrentGameUseCase.execute();
    final dayInfo = game.currentDayInfo;

    if (game.gameStatus == GameStatus.finished) {
      return true;
    }
    final allPlayers = playersRepository.getAllAvailablePlayers();
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

    if (!speakGamePhaseRepo.isFinished(day: dayInfo.day) ||
        !nightGamePhaseRepo.isFinished(day: dayInfo.day)) {
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

  Future<DayInfoModel> _goNextDay(int currentDay) async {
    MafLogger.d(_tag, 'Go to nex day');
    final nextDay = currentDay + 1;
    final lastDayInfo = await getLastDayInfoUseCase.execute();
    final DayInfoModel nextDayInfoModel;

    if (lastDayInfo.day != currentDay) {
      nextDayInfoModel = lastDayInfo;
      nextDayInfoModel.currentPhase = PhaseType.speak;
      await updateDayInfoUseCase.execute(params: nextDayInfoModel);
    } else {
      nextDayInfoModel = await createDayInfoUseCase.execute(
        params: CreateDayInfoParams(
          day: nextDay,
          initialGamePhase: PhaseType.speak,
        ),
      );
    }
    await playerManager.refreshMuteIfNeeded(nextDayInfoModel);
    gameHistoryManager.logNewDay(nextDay);
    _updateDayInfo(nextDayInfoModel);

    return await nextGamePhase();
  }

  Future<void> resetGameData() async {
    await removeGameDataUseCase.execute();
    votePhaseGameManager.reset();
    gameHistoryManager.reset();
    _gameSubject.add(null);
  }
}
