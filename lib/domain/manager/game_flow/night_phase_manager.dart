import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/manager/game_history_manager.dart';
import 'package:mafia_board/domain/manager/role_manager.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class NightPhaseManager {
  static const _tag = 'NightPhaseManager';
  final GamePhaseRepo<NightPhaseAction> nightGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final PlayersRepo boardRepository;
  final GameHistoryManager gameHistoryManager;
  final RoleManager roleManager;
  final GetCurrentGameUseCase getCurrentGameUseCase;

  NightPhaseManager({
    required this.nightGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.roleManager,
    required this.boardRepository,
    required this.gameHistoryManager,
    required this.getCurrentGameUseCase,
  });

  Future<NightPhaseAction?> getCurrentPhase([int? day]) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    return nightGamePhaseRepo.getCurrentPhase(
      day: day ?? currentDay,
    );
  }

  Future<void> preparedNightPhases(int currentDay) async {
    final List<NightPhaseAction> phases = [];
    roleManager.allRoles
        .where((roleModel) => roleModel.nightPriority >= 0)
        .sorted((a, b) => a.nightPriority.compareTo(b.nightPriority))
        .forEach((roleModel) {
      final playersByRole = boardRepository
          .getAllAvailablePlayers()
          .where((player) => player.role == roleModel.role)
          .toList();

      // workaround to add DON in MAFIA phase
      if (roleModel.role == Role.MAFIA) {
        final donPlayer = boardRepository
            .getAllAvailablePlayers()
            .firstWhereOrNull((player) => player.role == Role.DON);
        if (donPlayer != null) {
          playersByRole.add(donPlayer);
        }
      }

      phases.add(NightPhaseAction(
        currentDay: currentDay,
        role: roleModel.role,
        playersForWakeUp: playersByRole,
      ));
    });

    nightGamePhaseRepo.addAll(gamePhases: phases);
  }

  Future<void> startCurrentNightPhase() async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final phase = nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (phase == null) {
      return;
    }
    phase.status = PhaseStatus.inProgress;
    nightGamePhaseRepo.update(gamePhase: phase);
  }

  Future<void> finishCurrentNightPhase() async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final phase = nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (phase == null) {
      return;
    }
    phase.status = PhaseStatus.finished;
    nightGamePhaseRepo.update(gamePhase: phase);
  }

  Future<void> killPlayer(PlayerModel? playerModel) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final currentNightPhase =
        nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentNightPhase == null ||
        playerModel == null ||
        playerModel.isKilled ||
        await _isPlayerAlreadyKilledBefore(playerModel) ||
        playerModel.isKicked ||
        playerModel.isDisqualified) {
      gameHistoryManager.logKillPlayer(nightPhaseAction: currentNightPhase);
      return;
    }

    await cancelKillPlayer(currentNightPhase.killedPlayer);

    boardRepository.updatePlayer(playerModel.id, isKilled: true);
    final updatedPlayer = await boardRepository.getPlayerById(playerModel.id);
    final nextDay = currentDay + 1;
    await speakGamePhaseRepo.add(
      gamePhase: SpeakPhaseAction(
          currentDay: nextDay,
          playerId: updatedPlayer?.id,
          isLastWord: true,
          isBestMove: currentDay == Constants.firstDay),
    );
    currentNightPhase.killedPlayer = updatedPlayer;
    gameHistoryManager.logKillPlayer(
      player: updatedPlayer,
      nightPhaseAction: currentNightPhase,
    );
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  Future<void> cancelKillPlayer(PlayerModel? playerModel) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final currentNightPhase =
        nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentNightPhase == null ||
        playerModel == null ||
        !playerModel.isKilled ||
        await _isPlayerAlreadyKilledBefore(playerModel)) {
      MafLogger.d(_tag, "Can't cancel kill");
      gameHistoryManager.removeLogKillPlayer(
        nightPhaseAction: currentNightPhase,
      );
      return;
    }

    final nextDay = currentDay + 1;
    final speakPhase = speakGamePhaseRepo.getCurrentPhase(day: nextDay);
    final killedPlayer = currentNightPhase.killedPlayer;
    if (speakPhase == null || killedPlayer == null) {
      return;
    }

    await boardRepository.updatePlayer(killedPlayer.id, isKilled: false);
    if (speakPhase.isLastWord && speakPhase.playerId == playerModel.id) {
      speakGamePhaseRepo.remove(gamePhase: speakPhase);
    }
    gameHistoryManager.removeLogKillPlayer(
      nightPhaseAction: currentNightPhase,
    );
    currentNightPhase.killedPlayer = null;
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  Future<void> checkPlayer(PlayerModel? playerModel) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    await cancelCheckPlayer(playerModel);
    final currentNightPhase = nightGamePhaseRepo.getCurrentPhase(
      day: currentDay,
    );
    if (currentNightPhase == null) {
      return;
    }

    if (playerModel != null) {
      currentNightPhase.checkedPlayer = playerModel;
    }

    gameHistoryManager.logCheckPlayer(nightPhaseAction: currentNightPhase);
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  Future<void> cancelCheckPlayer(PlayerModel? playerModel) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final currentNightPhase =
        nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentNightPhase == null) {
      return;
    }
    currentNightPhase.checkedPlayer = null;
    gameHistoryManager.removeLogCheckPlayer(
        nightPhaseAction: currentNightPhase);
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  //todo: in progress
  Future<void> visitPlayer(PlayerModel? playerModel, Role whoIsVisiting) async {
    if (playerModel == null) {
      // didn't check OR no players with this role $whoIsChecking in game
      return;
    }
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final nextDay = currentDay + 1;
    if (whoIsVisiting == Role.DOCTOR) {
      final lastWordSpeakingPhase =
          speakGamePhaseRepo.getCurrentPhase(day: nextDay);
      if (lastWordSpeakingPhase != null && lastWordSpeakingPhase.isLastWord) {
        boardRepository.updatePlayer(playerModel.id, isKilled: false);
        speakGamePhaseRepo.remove(gamePhase: lastWordSpeakingPhase);
      }
    } else if (whoIsVisiting == Role.PUTANA) {
      boardRepository.updatePlayer(playerModel.id, isMuted: true);
    } else {
      // this role can't visit players
      return;
    }
  }

  Future<bool> _isPlayerAlreadyKilledBefore(PlayerModel playerModel) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    bool result = false;
    nightGamePhaseRepo.getAllPhases().forEach((phase) {
      if (currentDay < phase.currentDay &&
          phase.killedPlayer?.id == playerModel.id) {
        result = true;
        return;
      }
    });
    return result;
  }
}
