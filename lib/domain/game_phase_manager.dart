import 'dart:async';

import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:rxdart/rxdart.dart';

class GamePhaseManager {
  static const _tag = 'GamePhaseManager';

  final GamePhaseRepository gamePhaseRepository;
  final BoardRepository boardRepository;
  final GameHistoryManager gameHistoryManager;
  final BehaviorSubject<GamePhaseModel> _gamePhaseStreamController =
      BehaviorSubject();

  GamePhaseManager({
    required this.boardRepository,
    required this.gamePhaseRepository,
    required this.gameHistoryManager,
  });

  Stream<GamePhaseModel> get gamePhaseStream =>
      _gamePhaseStreamController.stream;

  Future<GamePhaseModel> get gamePhase async =>
      _gamePhaseStreamController.value;

  void _updateGamePhase(GamePhaseModel gamePhaseModel) {
    gamePhaseRepository.setCurrentGamePhase(gamePhaseModel);
    _gamePhaseStreamController.add(gamePhaseModel);
  }

  void startGame() {
    gamePhaseRepository.resetGamePhase();
    final phase = gamePhaseRepository.getCurrentGamePhase();
    _prepareSpeakPhases(phase);
    _updateGamePhase(phase);
    gameHistoryManager.logGameStart(gamePhaseModel: phase);
  }

  void nextGamePhase() {
    if (_isGameFinished()) {
      finishGame();
      return;
    }

    final phase = gamePhaseRepository.getCurrentGamePhase();

    if (!phase.isSpeakPhaseFinished()) {
      final currentSpeakPhase = phase.getCurrentSpeakPhase();
      if (currentSpeakPhase != null) {
        currentSpeakPhase.isFinished = true;
        // check in case current speaker was the last speaker
        if (!phase.isSpeakPhaseFinished()) {
          phase.updateSpeakPhase(currentSpeakPhase);
          _updateGamePhase(phase);
          gameHistoryManager.logPlayerSpeech(speakPhaseAction: currentSpeakPhase);
          return;
        }
      }
    }

    if (!phase.isVotingPhaseFinished() && _handleVotePhase(phase)) {
      return;
    }

    if (!phase.isNightPhaseFinished()) {
      final currentNightPhase = phase.getCurrentNightPhase();
      if (currentNightPhase != null) {
        currentNightPhase.isFinished = true;
        if (!phase.isNightPhaseFinished()) {
          phase.updateNightPhase(currentNightPhase);
          _updateGamePhase(phase);
          return;
        }
      }
    }
  }

  void finishGame() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    phase.isStarted = false;
    _updateGamePhase(phase);
    gameHistoryManager.logGameFinish(gamePhaseModel: phase);
  }

  void finishCurrentVotePhase() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final currentVotePhase = phase.getCurrentVotePhase();
    if (currentVotePhase != null) {
      currentVotePhase.isVoted = true;
      _updateGamePhase(phase);
      gameHistoryManager.logVoteFinish(votePhaseAction: currentVotePhase);
    }
  }

  void _prepareSpeakPhases(GamePhaseModel phase) {
    boardRepository.getAllPlayers().forEach((player) {
      if (!player.isRemoved && !player.isKilled) {
        phase.addSpeakPhase(
          SpeakPhaseAction(currentDay: phase.currentDay, player: player),
        );
      }
    });
  }

  bool _handleVotePhase(GamePhaseModel phase) {
    final currentVotePhase = phase.getCurrentVotePhase();
    final allVotePhases = phase.getUniqueTodaysVotePhases();
    if (currentVotePhase == null ||
        phase.currentDay == 0 && allVotePhases.length <= 1) {
      return false;
    }

    _updateGamePhase(phase);
    return true;
  }

  bool putOnVote(PlayerModel currentPlayer, PlayerModel playerToVote) {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    if (_isPlayerAlreadyPutOnVote(
        currentPlayer, phase.getUniqueTodaysVotePhases())) {
      final votePhase = VotePhaseAction(
        currentDay: phase.currentDay,
        playerOnVote: playerToVote,
        whoPutOnVote: currentPlayer,
      );
      phase.addVotePhase(votePhase);
      gameHistoryManager.logPutOnVote(votePhaseAction: votePhase);
      return true;
    }
    return false;
  }

  bool voteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final result = phase.voteAgainst(
      currentPlayer: currentPlayer,
      voteAgainstPlayer: voteAgainstPlayer,
    );
    _updateGamePhase(phase);
    return result;
  }

  bool cancelVoteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final result = phase.cancelVoteAgainst(
      currentPlayer: currentPlayer,
      voteAgainstPlayer: voteAgainstPlayer,
    );
    _updateGamePhase(phase);
    return result;
  }

  bool _isPlayerAlreadyPutOnVote(
    PlayerModel playerModel,
    List<VotePhaseAction> allUniqueTodayVotePhases,
  ) {
    bool isVoted = true;

    for (var phase in allUniqueTodayVotePhases) {
      isVoted = phase.whoPutOnVote.id != playerModel.id;
    }

    return isVoted;
  }

  void addFoul(PlayerModel player) {}

  bool _isGameFinished() {
    final allPlayers = boardRepository.getAllAvailablePlayers();
    int mafsCount = allPlayers
        .where((player) => player.role == Role.MAFIA || player.role == Role.DON)
        .length;

    int civilianCount = allPlayers
        .where(
          (player) =>
              player.role == Role.CIVILIAN ||
              player.role == Role.SHERIFF ||
              player.role == Role.DOCTOR ||
              player.role == Role.PUTANA ||
              player.role == Role.MANIAC,
        )
        .length;

    if (mafsCount >= civilianCount) {
      return true;
    }

    if (mafsCount <= 0) {
      return true;
    }

    return false;
  }
}
