import 'package:collection/collection.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/role_manager.dart';

class NightPhaseManager {
  final GamePhaseRepository gamePhaseRepository;
  final BoardRepository boardRepository;
  final GameHistoryManager gameHistoryManager;
  final RoleManager roleManager;
  void Function(GamePhaseModel)? updateGamePhase;

  NightPhaseManager({
    required this.gamePhaseRepository,
    required this.roleManager,
    required this.boardRepository,
    required this.gameHistoryManager,
  });

  set setUpdateGamePhase(
    Function(GamePhaseModel)? updateGamePhase,
  ) =>
      this.updateGamePhase = updateGamePhase;

  List<NightPhaseAction> getPreparedNightPhases(int currentDay) {
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
    return phases;
  }

  void startCurrentNightPhase() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    phase.getCurrentNightPhase()?.status = PhaseStatus.inProgress;
    gamePhaseRepository.setCurrentGamePhase(phase);
  }

  void finishCurrentNightPhase() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    phase.getCurrentNightPhase()?.status = PhaseStatus.finished;
    gamePhaseRepository.setCurrentGamePhase(phase);
  }

  void killPlayer(PlayerModel? playerModel) {
    if (playerModel == null) {
      gameHistoryManager.logKillPlayer();
      return;
    }

    cancelKillPlayer(playerModel);

    final phase = gamePhaseRepository.getCurrentGamePhase();
    final currentNightPhase = phase.getCurrentNightPhase();
    boardRepository.updatePlayer(playerModel.id, isKilled: true);
    final nextDay = phase.currentDay + 1;
    phase.addSpeakPhase(
      SpeakPhaseAction(
          currentDay: nextDay, player: playerModel, isLastWord: true),
      nextDay,
    );
    phase.getCurrentNightPhase()?.killedPlayer = playerModel;
    gameHistoryManager.logKillPlayer(
      player: playerModel,
      nightPhaseAction: currentNightPhase,
    );
    gamePhaseRepository.setCurrentGamePhase(phase);
  }

  void cancelKillPlayer(PlayerModel? playerModel) {
    if (playerModel == null) {
      // miss
      return;
    }

    final phase = gamePhaseRepository.getCurrentGamePhase();
    final nextDay = phase.currentDay + 1;
    final speakPhase = phase.getCurrentSpeakPhase(nextDay);
    final currentNightPhase = phase.getCurrentNightPhase();
    final killedPlayer = currentNightPhase?.killedPlayer;
    if (speakPhase == null ||
        currentNightPhase == null ||
        killedPlayer == null) {
      return;
    }

    boardRepository.updatePlayer(killedPlayer.id, isKilled: false);
    if (speakPhase.isLastWord && speakPhase.player?.id == playerModel.id) {
      phase.removeSpeakPhase(speakPhase, nextDay);
    }
    gameHistoryManager.removeLogKillPlayer(
      nightPhaseAction: currentNightPhase,
    );
    currentNightPhase.killedPlayer = null;
    gamePhaseRepository.setCurrentGamePhase(phase);
  }

  void checkPlayer(PlayerModel? playerModel) {
    cancelCheckPlayer(playerModel);
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final currentNightPhase = phase.getCurrentNightPhase();
    if (currentNightPhase == null) {
      return;
    }

    if (playerModel != null) {
      currentNightPhase.checkedPlayer = playerModel;
    }

    gameHistoryManager.logCheckPlayer(nightPhaseAction: currentNightPhase);
    gamePhaseRepository.setCurrentGamePhase(phase);
  }

  void cancelCheckPlayer(PlayerModel? playerModel) {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final currentNightPhase = phase.getCurrentNightPhase();
    if (currentNightPhase == null) {
      return;
    }
    currentNightPhase.checkedPlayer = null;
    gameHistoryManager.removeLogCheckPlayer(nightPhaseAction: currentNightPhase);
    gamePhaseRepository.setCurrentGamePhase(phase);
  }

  //todo: in progress
  void visitPlayer(PlayerModel? playerModel, Role whoIsVisiting) {
    if (playerModel == null) {
      // didn't check OR no players with this role $whoIsChecking in game
      return;
    }

    if (whoIsVisiting == Role.DOCTOR) {
      final phase = gamePhaseRepository.getCurrentGamePhase();
      final lastWordSpeakingPhase =
          phase.getCurrentSpeakPhase(phase.currentDay + 1);
      if (lastWordSpeakingPhase != null && lastWordSpeakingPhase.isLastWord) {
        boardRepository.updatePlayer(playerModel.id, isKilled: false);
        phase.removeSpeakPhase(lastWordSpeakingPhase, phase.currentDay + 1);
      }
    } else if (whoIsVisiting == Role.PUTANA) {
      boardRepository.updatePlayer(playerModel.id, isMuted: true);
    } else {
      // this role can't visit players
      return;
    }
  }
}
