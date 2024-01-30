import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
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
  final GamePhaseRepo<NightPhaseModel> nightGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;
  final PlayersRepo playersRepository;
  final GameHistoryManager gameHistoryManager;
  final RoleManager roleManager;
  final GetCurrentGameUseCase getCurrentGameUseCase;

  NightPhaseManager({
    required this.nightGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.roleManager,
    required this.playersRepository,
    required this.gameHistoryManager,
    required this.getCurrentGameUseCase,
  });

  Future<NightPhaseModel?> getCurrentPhase([int? day]) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    return nightGamePhaseRepo.getCurrentPhase(
      day: day ?? currentDay,
    );
  }

  Future<void> preparedNightPhases(int currentDay) async {
    final List<NightPhaseModel> phases = [];
    roleManager.allRoles
        .where((roleModel) => roleModel.nightPriority >= 0)
        .sorted((a, b) => a.nightPriority.compareTo(b.nightPriority))
        .forEach((roleModel) {
      final playersByRole = playersRepository
          .getAllAvailablePlayers()
          .where((player) => player.role == roleModel.role)
          .toList();

      // workaround to add DON in MAFIA phase
      if (roleModel.role == Role.mafia) {
        final donPlayer = playersRepository
            .getAllAvailablePlayers()
            .firstWhereOrNull((player) => player.role == Role.don);
        if (donPlayer != null) {
          playersByRole.add(donPlayer);
        }
      }

      phases.add(NightPhaseModel(
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

  Future<void> killPlayer(PlayerModel? player) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final currentNightPhase =
        nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentNightPhase == null ||
        player == null ||
        player.isKilled ||
        await _isPlayerAlreadyKilledBefore(player) ||
        player.isKicked ||
        player.isDisqualified) {
      gameHistoryManager.logKillPlayer(nightPhaseAction: currentNightPhase);
      return;
    }

    await cancelKillPlayer(currentNightPhase.killedPlayer);

    playersRepository.updatePlayer(player.tempId, isKilled: true);
    final updatedPlayer = await playersRepository.getPlayerById(player.tempId);
    final nextDay = currentDay + 1;
    await speakGamePhaseRepo.add(
      gamePhase: SpeakPhaseModel(
          currentDay: nextDay,
          playerTempId: updatedPlayer?.tempId,
          isLastWord: true,
          isBestMove: currentDay == Constants.firstDay),
    );
    currentNightPhase.kill(updatedPlayer);
    gameHistoryManager.logKillPlayer(
      player: updatedPlayer,
      nightPhaseAction: currentNightPhase,
    );
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  Future<void> cancelKillPlayer(PlayerModel? player) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final currentNightPhase =
        nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentNightPhase == null ||
        player == null ||
        !player.isKilled ||
        await _isPlayerAlreadyKilledBefore(player)) {
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

    await playersRepository.updatePlayer(killedPlayer.tempId, isKilled: false);
    if (speakPhase.isLastWord && speakPhase.playerTempId == player.tempId) {
      speakGamePhaseRepo.remove(gamePhase: speakPhase);
    }
    gameHistoryManager.removeLogKillPlayer(
      nightPhaseAction: currentNightPhase,
    );
    currentNightPhase.revokeKill();
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  Future<void> checkPlayer(PlayerModel? player) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    await cancelCheckPlayer(player);
    final currentNightPhase = nightGamePhaseRepo.getCurrentPhase(
      day: currentDay,
    );
    if (currentNightPhase == null) {
      return;
    }

    if (player != null) {
      currentNightPhase.check(player);
    }

    gameHistoryManager.logCheckPlayer(nightPhaseAction: currentNightPhase);
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  Future<void> cancelCheckPlayer(PlayerModel? player) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final currentNightPhase =
        nightGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentNightPhase == null) {
      return;
    }
    currentNightPhase.revokeCheck();
    gameHistoryManager.removeLogCheckPlayer(
        nightPhaseAction: currentNightPhase);
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  //todo: in progress
  Future<void> visitPlayer(PlayerModel? player, Role whoIsVisiting) async {
    if (player == null) {
      // didn't check OR no players with this role $whoIsChecking in game
      return;
    }
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final nextDay = currentDay + 1;
    if (whoIsVisiting == Role.doctor) {
      final lastWordSpeakingPhase =
          speakGamePhaseRepo.getCurrentPhase(day: nextDay);
      if (lastWordSpeakingPhase != null && lastWordSpeakingPhase.isLastWord) {
        playersRepository.updatePlayer(player.tempId, isKilled: false);
        speakGamePhaseRepo.remove(gamePhase: lastWordSpeakingPhase);
      }
    } else if (whoIsVisiting == Role.putana) {
      playersRepository.updatePlayer(player.tempId, isMuted: true);
    } else {
      // this role can't visit players
      return;
    }
  }

  Future<bool> _isPlayerAlreadyKilledBefore(PlayerModel player) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    bool result = false;
    nightGamePhaseRepo.getAllPhases().forEach((phase) {
      if (currentDay < phase.currentDay &&
          phase.killedPlayer?.tempId == player.tempId) {
        result = true;
        return;
      }
    });
    return result;
  }
}
