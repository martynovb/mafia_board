import 'dart:async';

import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/night_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:rxdart/rxdart.dart';

class GamePhaseManager {
  static const _tag = 'GamePhaseManager';

  final GamePhaseRepository gamePhaseRepository;
  final BoardRepository boardRepository;
  final GameHistoryManager gameHistoryManager;
  final VotePhaseManager votePhaseGameManager;
  final SpeakingPhaseManager speakingPhaseManager;
  final NightPhaseManager nightPhaseManager;
  final BehaviorSubject<GamePhaseModel> _gamePhaseStreamController =
      BehaviorSubject();

  GamePhaseManager({
    required this.boardRepository,
    required this.gamePhaseRepository,
    required this.gameHistoryManager,
    required this.votePhaseGameManager,
    required this.speakingPhaseManager,
    required this.nightPhaseManager,
  }) {
    votePhaseGameManager.setUpdateGamePhase = _updateGamePhase;
    speakingPhaseManager.setUpdateGamePhase = _updateGamePhase;
    nightPhaseManager.setUpdateGamePhase = _updateGamePhase;
  }

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
    phase.isStarted = true;
    phase.addAllSpeakPhases(
      speakingPhaseManager.getPreparedSpeakPhases(phase.currentDay),
    );
    _updateGamePhase(phase);
    gameHistoryManager.logGameStart(gamePhaseModel: phase);
  }

  void nextGamePhase() {
    if (_isGameFinished()) {
      finishGame();
      return;
    }

    final phase = gamePhaseRepository.getCurrentGamePhase();

    if (!phase.isSpeakingPhasesExist()) {
      phase.addAllSpeakPhases(
        speakingPhaseManager.getPreparedSpeakPhases(phase.currentDay),
      );
      _updateGamePhase(phase);
    }

    if (!phase.isSpeakPhaseFinished()) {
      return;
    }

    if (!phase.isVotingPhaseFinished() &&
        !votePhaseGameManager.canSkipVotePhase(phase)) {
      return;
    }

    if (!phase.isNightPhasesExist()) {
      phase.addAllNightPhases(
        nightPhaseManager.getPreparedNightPhases(phase.currentDay),
      );
      _updateGamePhase(phase);
    }

    if (!phase.isNightPhaseFinished()) {
      return;
    }

    phase.increaseDay();
    nextGamePhase();
  }

  void finishGame() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    phase.isStarted = false;
    _updateGamePhase(phase);
    gameHistoryManager.logGameFinish(gamePhaseModel: phase);
  }

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

  // SPEAK PHASE

  void startSpeech() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    speakingPhaseManager.startSpeech(phase);
  }

  void finishSpeech() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    speakingPhaseManager.finishSpeech(phase);
  }

  // VOTE PHASE

  bool putOnVote({
    required PlayerModel currentPlayer,
    required PlayerModel playerToVote,
  }) =>
      votePhaseGameManager.putOnVote(currentPlayer, playerToVote);

  void finishCurrentVotePhase() =>
      votePhaseGameManager.finishCurrentVotePhase();

  bool voteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) =>
      votePhaseGameManager.voteAgainst(
        currentPlayer: currentPlayer,
        voteAgainstPlayer: voteAgainstPlayer,
      );

  bool cancelVoteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) =>
      votePhaseGameManager.cancelVoteAgainst(
        currentPlayer: currentPlayer,
        voteAgainstPlayer: voteAgainstPlayer,
      );

  Map<PlayerModel, bool> calculatePlayerVotingStatusMap(GamePhaseModel phase) =>
      votePhaseGameManager.calculatePlayerVotingStatusMap(phase);

  // NIGHT PHASE

  void startCurrentNightPhase() => nightPhaseManager.startCurrentNightPhase();

  NightPhaseAction? getCurrentNightPhase() =>
      gamePhaseRepository.getCurrentGamePhase().getCurrentNightPhase();

  void finishCurrentNightPhase() => nightPhaseManager.finishCurrentNightPhase();

  void killPlayer(PlayerModel playerModel) {
    nightPhaseManager.killPlayer(playerModel);
  }

  void cancelKillPlayer(PlayerModel playerModel) {
    nightPhaseManager.cancelKillPlayer(playerModel);
  }

  void checkPlayer(PlayerModel playerModel) =>
      nightPhaseManager.checkPlayer(playerModel);

  void cancelCheckPlayer(PlayerModel playerModel) =>
      nightPhaseManager.cancelCheckPlayer(playerModel);

  void visitPlayer(PlayerModel playerModel, Role whoIsVisiting) =>
      nightPhaseManager.visitPlayer(playerModel, whoIsVisiting);
}
