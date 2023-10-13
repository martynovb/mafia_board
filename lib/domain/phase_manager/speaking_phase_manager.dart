import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';

class SpeakingPhaseManager {
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final BoardRepo boardRepository;
  final GameHistoryManager gameHistoryManager;

  SpeakingPhaseManager({
    required this.speakGamePhaseRepo,
    required this.boardRepository,
    required this.gameHistoryManager,
  });

  SpeakPhaseAction? getCurrentPhase() => speakGamePhaseRepo.getCurrentPhase();

  void preparedSpeakPhases(int currentDay) {
    boardRepository.getAllAvailablePlayers().forEach((player) {
      speakGamePhaseRepo.add(
        gamePhase: SpeakPhaseAction(currentDay: currentDay, player: player),
      );
    });
  }

  void startSpeech() {
    final currentSpeakPhase = speakGamePhaseRepo.getCurrentPhase();
    if (currentSpeakPhase == null) {
      return;
    }
    currentSpeakPhase.updateStatus = PhaseStatus.inProgress;
    speakGamePhaseRepo.update(gamePhase: currentSpeakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
  }

  void finishSpeech() {
    final currentSpeakPhase = speakGamePhaseRepo.getCurrentPhase();
    if (currentSpeakPhase == null) {
      return;
    }
    currentSpeakPhase.updateStatus = PhaseStatus.finished;
    speakGamePhaseRepo.update(gamePhase: currentSpeakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
  }
}
