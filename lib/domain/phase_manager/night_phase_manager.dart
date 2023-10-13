import 'package:collection/collection.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class NightPhaseManager {
  static const _tag = 'NightPhaseManager';
  final GameInfoRepo gameInfoRepo;
  final GamePhaseRepo<NightPhaseAction> nightGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final BoardRepo boardRepository;
  final GameHistoryManager gameHistoryManager;
  final RoleManager roleManager;

  NightPhaseManager({
    required this.gameInfoRepo,
    required this.nightGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.roleManager,
    required this.boardRepository,
    required this.gameHistoryManager,
  });

  NightPhaseAction? getCurrentPhase() => nightGamePhaseRepo.getCurrentPhase();

  void preparedNightPhases(int currentDay) {
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
  }

  void startCurrentNightPhase() {
    final phase = nightGamePhaseRepo.getCurrentPhase();
    if (phase == null) {
      return;
    }
    phase.status = PhaseStatus.inProgress;
    nightGamePhaseRepo.update(gamePhase: phase);
  }

  void finishCurrentNightPhase() {
    final phase = nightGamePhaseRepo.getCurrentPhase();
    if (phase == null) {
      return;
    }
    phase.status = PhaseStatus.finished;
    nightGamePhaseRepo.update(gamePhase: phase);
  }

  Future<void> killPlayer(PlayerModel? playerModel) async {
    final currentNightPhase = nightGamePhaseRepo.getCurrentPhase();
    if (currentNightPhase == null ||
        playerModel == null ||
        playerModel.isKilled ||
        await _isPlayerAlreadyKilledBefore(playerModel) ||
        playerModel.isKicked ||
        playerModel.isRemoved) {
      gameHistoryManager.logKillPlayer(nightPhaseAction: currentNightPhase);
      return;
    }

    cancelKillPlayer(currentNightPhase.killedPlayer);

    boardRepository.updatePlayer(playerModel.id, isKilled: true);
    final nextDay = (await gameInfoRepo.getCurrentDay()) + 1;
    speakGamePhaseRepo.add(
      gamePhase: SpeakPhaseAction(
          currentDay: nextDay, player: playerModel, isLastWord: true),
    );
    currentNightPhase.killedPlayer = playerModel;
    gameHistoryManager.logKillPlayer(
      player: playerModel,
      nightPhaseAction: currentNightPhase,
    );
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  Future<void> cancelKillPlayer(PlayerModel? playerModel) async {
    final currentNightPhase = nightGamePhaseRepo.getCurrentPhase();
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

    final nextDay = (await gameInfoRepo.getCurrentDay()) + 1;
    final speakPhase = speakGamePhaseRepo.getCurrentPhase(day: nextDay);
    final killedPlayer = currentNightPhase.killedPlayer;
    if (speakPhase == null || killedPlayer == null) {
      return;
    }

    boardRepository.updatePlayer(killedPlayer.id, isKilled: false);
    if (speakPhase.isLastWord && speakPhase.player?.id == playerModel.id) {
      speakGamePhaseRepo.remove(gamePhase: speakPhase);
    }
    gameHistoryManager.removeLogKillPlayer(
      nightPhaseAction: currentNightPhase,
    );
    currentNightPhase.killedPlayer = null;
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  void checkPlayer(PlayerModel? playerModel) {
    cancelCheckPlayer(playerModel);
    final currentNightPhase = nightGamePhaseRepo.getCurrentPhase();
    if (currentNightPhase == null) {
      return;
    }

    if (playerModel != null) {
      currentNightPhase.checkedPlayer = playerModel;
    }

    gameHistoryManager.logCheckPlayer(nightPhaseAction: currentNightPhase);
    nightGamePhaseRepo.update(gamePhase: currentNightPhase);
  }

  void cancelCheckPlayer(PlayerModel? playerModel) {
    final currentNightPhase = nightGamePhaseRepo.getCurrentPhase();
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

    final nextDay = (await gameInfoRepo.getCurrentDay()) + 1;
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
    final currentDay = await gameInfoRepo.getCurrentDay();
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
