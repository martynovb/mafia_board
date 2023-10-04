import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/speak_phase_status.dart';
import 'package:mafia_board/domain/game_history_manager.dart';

class SpeakingPhaseManager {
  final BoardRepository boardRepository;
  final GameHistoryManager gameHistoryManager;
  void Function(GamePhaseModel)? updateGamePhase;

  SpeakingPhaseManager({
    required this.boardRepository,
    required this.gameHistoryManager,
  });

  set setUpdateGamePhase(
    Function(GamePhaseModel)? updateGamePhase,
  ) =>
      this.updateGamePhase = updateGamePhase;

  List<SpeakPhaseAction> getPreparedSpeakPhases(int currentDay) {
    final List<SpeakPhaseAction> phases = [];
    boardRepository.getAllPlayers().forEach((player) {
      if (!player.isRemoved && !player.isKilled) {
        phases.add(
          SpeakPhaseAction(currentDay: currentDay, player: player),
        );
      }
    });
    return phases;
  }

  void startSpeech(GamePhaseModel phase) {
    final currentSpeakPhase = phase.getCurrentSpeakPhase();
    currentSpeakPhase?.updateStatus = SpeakPhaseStatus.speaking;
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
    updateGamePhase!(phase);
  }

  void finishSpeech(GamePhaseModel phase) {
    final currentSpeakPhase = phase.getCurrentSpeakPhase();
    currentSpeakPhase?.updateStatus = SpeakPhaseStatus.finished;
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
    updateGamePhase!(phase);
  }
}
