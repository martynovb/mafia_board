import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/game_info/day_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';

class SpeakingPhaseManager {
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final PlayersRepo boardRepository;
  final DayInfoRepo dayInfoRepo;
  final GameHistoryManager gameHistoryManager;

  SpeakingPhaseManager({
    required this.speakGamePhaseRepo,
    required this.dayInfoRepo,
    required this.boardRepository,
    required this.gameHistoryManager,
  });

  Future<SpeakPhaseAction?> getCurrentPhase([int? day]) async =>
      speakGamePhaseRepo.getCurrentPhase(
        day: day ?? await dayInfoRepo.getCurrentDay(),
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
    final currentDay = await dayInfoRepo.getCurrentDay();
    final currentSpeakPhase =
        speakGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentSpeakPhase == null) {
      return;
    }
    currentSpeakPhase.updateStatus = PhaseStatus.inProgress;
    speakGamePhaseRepo.update(gamePhase: currentSpeakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
  }

  Future<void> finishSpeech([
    List<int> bestMove = const [],
  ]) async {
    final currentDay = await dayInfoRepo.getCurrentDay();
    final currentSpeakPhase =
        speakGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentSpeakPhase == null) {
      return;
    }
    currentSpeakPhase.updateStatus = PhaseStatus.finished;
    currentSpeakPhase.bestMove = bestMove;
    speakGamePhaseRepo.update(gamePhase: currentSpeakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
  }
}
