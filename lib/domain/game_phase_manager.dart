import 'dart:async';

import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/data/model/game_phase/pick_roles_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class GamePhaseManager {
  static const _tag = 'GamePhaseManager';

  final GamePhaseRepository gamePhaseRepository;
  final BoardRepository boardRepository;
  final StreamController<GamePhaseModel> _gamePhaseStreamController =
      StreamController.broadcast();

  GamePhaseManager({
    required this.boardRepository,
    required this.gamePhaseRepository,
  });

  Stream<GamePhaseModel> get gamePhaseStream =>
      _gamePhaseStreamController.stream;

  void _updateGamePhase(GamePhaseModel gamePhaseModel) {
    gamePhaseRepository.setCurrentGamePhase(gamePhaseModel);
    _gamePhaseStreamController.add(gamePhaseModel);
  }

  void startGame() {
    gamePhaseRepository.resetGamePhase();
    final phase = gamePhaseRepository.getCurrentGamePhase();
    _prepareSpeakPhases(phase);
    _updateGamePhase(phase);
  }

  void nextGamePhase() {
    if (_isGameFinished()) {
      finishGame();
      return;
    }

    final phase = gamePhaseRepository.getCurrentGamePhase();

    if (!phase.isSpeakPhaseFinished()) {
      final currentSpeaker = phase.getCurrentSpeakPhase();
      currentSpeaker.isFinished = true;
      // check in case current speaker was the last speaker
      if(!phase.isSpeakPhaseFinished()) {
        phase.updateSpeakPhase(currentSpeaker);
        _updateGamePhase(phase);
        return;
      }
    }

    if(!phase.isVotingPhaseFinished()){
      final onVoteNow = phase.getCurrentVotePhase();
      onVoteNow.isVoted = true;
      if(!phase.isVotingPhaseFinished()) {
        phase.updateVotePhase(onVoteNow);
        _updateGamePhase(phase);
        return;
      }
    }

    if(!phase.isNightPhaseFinished()){
      final nightPhase = phase.getCurrentNightPhase();
      nightPhase.isFinished = true;
      if(!phase.isNightPhaseFinished()) {
        phase.updateNightPhase(nightPhase);
        _updateGamePhase(phase);
        return;
      }
    }

  }

  void finishGame() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    phase.isStarted = false;
    _updateGamePhase(phase);
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

  void _prepareNightPhases(GamePhaseModel phase) {
    boardRepository.getAllPlayers().forEach((player) {
      if (!player.isRemoved && !player.isKilled) {
        phase.addSpeakPhase(
          SpeakPhaseAction(currentDay: phase.currentDay, player: player),
        );
      }
    });
  }

  void putOnVote(PlayerModel currentPlayer, PlayerModel playerToVote) {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    phase.addVotePhase(VotePhaseAction(
      currentDay: phase.currentDay,
      playerOnVote: playerToVote,
      whoPutOnVote: currentPlayer,
    ));
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
