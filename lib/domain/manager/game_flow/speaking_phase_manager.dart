import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/manager/game_history_manager.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';

class SpeakingPhaseManager {
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final PlayersRepo boardRepository;
  final GameHistoryManager gameHistoryManager;
  final GetCurrentGameUseCase getCurrentGameUseCase;

  SpeakingPhaseManager({
    required this.speakGamePhaseRepo,
    required this.boardRepository,
    required this.gameHistoryManager,
    required this.getCurrentGameUseCase,
  });

  Future<SpeakPhaseAction?> getCurrentPhase([int? day]) async {
    final game = await getCurrentGameUseCase.execute();
    return speakGamePhaseRepo.getCurrentPhase(
      day: day ?? game.currentDayInfo.day,
    );
  }

  Future<void> preparedSpeakPhases(int currentDay) async {
    final List<SpeakPhaseAction> speakPhaseList = [];
    final players = boardRepository.getAllPlayers();

    if (players.isEmpty) throw Exception('preparedSpeakPhases: no players');

    int startIndex = (currentDay - 1) % players.length;
    final reorderedPlayers = players.sublist(startIndex)
      ..addAll(players.sublist(0, startIndex));
    for (var player in reorderedPlayers) {
      if (!player.isInGame()) {
        continue;
      }
      speakPhaseList.add(
        SpeakPhaseAction(
          currentDay: currentDay,
          playerId: player.tempId,
          timeForSpeakInSec: player.isMuted
              ? Constants.mutedTimeForSpeak
              : Constants.defaultTimeForSpeak,
        ),
      );
    }
    speakGamePhaseRepo.addAll(gamePhases: speakPhaseList);
  }

  Future<void> startSpeech() async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
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
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
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
