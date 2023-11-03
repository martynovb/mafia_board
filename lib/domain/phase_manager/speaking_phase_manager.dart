import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';

class SpeakingPhaseManager {
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final BoardRepo boardRepository;
  final GameInfoRepo gameInfoRepo;
  final GameHistoryManager gameHistoryManager;

  SpeakingPhaseManager({
    required this.speakGamePhaseRepo,
    required this.gameInfoRepo,
    required this.boardRepository,
    required this.gameHistoryManager,
  });

  Future<SpeakPhaseAction?> getCurrentPhase([int? day]) async =>
      speakGamePhaseRepo.getCurrentPhase(
        day: day ?? await gameInfoRepo.getCurrentDay(),
      );

  Future<void> preparedSpeakPhases(int currentDay) async {
    final List<SpeakPhaseAction> speakPhaseList = [];
    final players = boardRepository.getAllAvailablePlayers();

    if (players.isEmpty) return;

    int startIndex = (currentDay - 1) % players.length;
    final reorderedPlayers = players.sublist(startIndex)
      ..addAll(players.sublist(0, startIndex));
    for (var player in reorderedPlayers) {
      speakPhaseList.add(
        SpeakPhaseAction(
          currentDay: currentDay,
          playerId: player.id,
          timeForSpeakInSec: player.isMuted
              ? Constants.mutedTimeForSpeak
              : Constants.defaultTimeForSpeak,
        ),
      );
    }
    speakGamePhaseRepo.addAll(gamePhases: speakPhaseList);
  }

  Future<void> startSpeech() async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final currentSpeakPhase =
        speakGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentSpeakPhase == null) {
      return;
    }
    currentSpeakPhase.updateStatus = PhaseStatus.inProgress;
    speakGamePhaseRepo.update(gamePhase: currentSpeakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
  }

  Future<void> finishSpeech() async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final currentSpeakPhase =
        speakGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentSpeakPhase == null) {
      return;
    }
    currentSpeakPhase.updateStatus = PhaseStatus.finished;
    speakGamePhaseRepo.update(gamePhase: currentSpeakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
  }
}
