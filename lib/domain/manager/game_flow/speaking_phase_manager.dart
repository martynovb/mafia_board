import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/manager/game_history_manager.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';

class SpeakingPhaseManager {
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;
  final PlayersRepo playersRepository;
  final GameHistoryManager gameHistoryManager;
  final GetCurrentGameUseCase getCurrentGameUseCase;

  SpeakingPhaseManager({
    required this.speakGamePhaseRepo,
    required this.playersRepository,
    required this.gameHistoryManager,
    required this.getCurrentGameUseCase,
  });

  Future<SpeakPhaseModel?> getCurrentPhase([int? day]) async {
    final game = await getCurrentGameUseCase.execute();
    return speakGamePhaseRepo.getCurrentPhase(
      day: day ?? game.currentDayInfo.day,
    );
  }

  Future<void> preparedSpeakPhases(int currentDay) async {
    final List<SpeakPhaseModel> speakPhaseList = [];
    final players = playersRepository.getAllPlayers();

    if (players.isEmpty) throw Exception('preparedSpeakPhases: no players');

    int startIndex = (currentDay - 1) % players.length;
    final reorderedPlayers = players.sublist(startIndex)
      ..addAll(players.sublist(0, startIndex));
    for (var player in reorderedPlayers) {
      if (!player.isInGame()) {
        continue;
      }
      speakPhaseList.add(
        SpeakPhaseModel(
          currentDay: currentDay,
          playerTempId: player.tempId,
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
    currentSpeakPhase.bestMove = playersRepository
        .getAllPlayers()
        .where((player) => bestMove.contains(player.seatNumber))
        .toList();
    speakGamePhaseRepo.update(gamePhase: currentSpeakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
  }
}
