import 'package:collection/collection.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/domain/game_history_manager.dart';

class VotePhaseManager {
  final GamePhaseRepository gamePhaseRepository;
  final GameHistoryManager gameHistoryManager;
  final BoardRepository boardRepository;
  void Function(GamePhaseModel)? updateGamePhase;

  VotePhaseManager({
    required this.gamePhaseRepository,
    required this.gameHistoryManager,
    required this.boardRepository,
  });

  set setUpdateGamePhase(
    Function(GamePhaseModel)? updateGamePhase,
  ) =>
      this.updateGamePhase = updateGamePhase;

  void finishCurrentVotePhase() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final currentVotePhase = phase.getCurrentVotePhase();
    if (currentVotePhase != null) {
      currentVotePhase.isVoted = true;
      phase.updateVotePhase(currentVotePhase);
      updateGamePhase!(phase);
      gameHistoryManager.logVoteFinish(votePhaseAction: currentVotePhase);
      _recalculateVotePhases(phase);
    }
  }

  bool putOnVote(PlayerModel currentPlayer, PlayerModel playerToVote) {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    if (_isPlayerAlreadyPutOnVote(
          currentPlayer,
          phase.getUniqueTodaysVotePhases(),
        ) &&
        !_isPlayerAlreadyOnOnVote(
          playerToVote,
          phase.getUniqueTodaysVotePhases(),
        )) {
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
    updateGamePhase!(phase);
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
    updateGamePhase!(phase);
    return result;
  }

  void _recalculateVotePhases(GamePhaseModel phase) {
    final unvotedPlayers = calculatePlayerVotingStatusMap(phase)
        .entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    //when all players voted even if some vote phases are left
    if (unvotedPlayers.isEmpty) {
      _handlePlayerToKick(phase);
      return;
    }

    var unvotedPhases = phase
        .getUniqueTodaysVotePhases()
        .where((votePhase) => !votePhase.isVoted)
        .toList();

    //when only 1 vote phase is left add all left players to voted
    if (unvotedPhases.length == 1) {
      final unvotedPhase = unvotedPhases.firstOrNull;
      if (unvotedPhase != null) {
        unvotedPhase.isVoted = true;
        unvotedPhase.voteList(unvotedPlayers);
        phase.updateVotePhase(unvotedPhase);
        gameHistoryManager.logVoteFinish(votePhaseAction: unvotedPhase);
        updateGamePhase!(phase);
        _handlePlayerToKick(phase);
        return;
      }
    }
  }

  bool _isPlayerAlreadyPutOnVote(
    PlayerModel playerModel,
    List<VotePhaseAction> allUniqueTodayVotePhases,
  ) {
    for (var phase in allUniqueTodayVotePhases) {
      if (phase.whoPutOnVote.id == playerModel.id) {
        return false;
      }
    }
    return true;
  }

  bool _isPlayerAlreadyOnOnVote(
    PlayerModel playerModel,
    List<VotePhaseAction> allUniqueTodayVotePhases,
  ) {
    for (var phase in allUniqueTodayVotePhases) {
      if (phase.playerOnVote.id == playerModel.id) {
        return true;
      }
    }
    return false;
  }

  void _handlePlayerToKick(GamePhaseModel phase) {
    final playerToKick = _findPlayerToKick(phase.getUniqueTodaysVotePhases());
    final speakPhase = SpeakPhaseAction(
      currentDay: phase.currentDay,
      player: playerToKick,
      isLastWord: true,
    );
    phase.addSpeakPhase(speakPhase);
    gameHistoryManager.logPlayerSpeech(speakPhaseAction: speakPhase);
    updateGamePhase!(phase);
  }

  PlayerModel? _findPlayerToKick(List<VotePhaseAction> allVotePhases) =>
      allVotePhases
          .sorted(
              (a, b) => a.votedPlayers.length.compareTo(b.votedPlayers.length))
          .lastOrNull
          ?.playerOnVote;

  Map<PlayerModel, bool> calculatePlayerVotingStatusMap(GamePhaseModel phase) {
    final allTodayVotePhases = phase.getUniqueTodaysVotePhases();
    final allAvailablePlayers = boardRepository.getAllAvailablePlayers();
    final Map<PlayerModel, bool> playerVotingStatusMap = {};

    for (var player in allAvailablePlayers) {
      bool playerHasAlreadyVoted = allTodayVotePhases
          .any((votePhase) => votePhase.votedPlayers.contains(player));
      playerVotingStatusMap[player] = playerHasAlreadyVoted;
    }

    return playerVotingStatusMap;
  }

  bool canSkipVotePhase(GamePhaseModel phase) {
    final currentVotePhase = phase.getCurrentVotePhase();
    final allVotePhases = phase.getUniqueTodaysVotePhases();
    if (currentVotePhase == null ||
        phase.currentDay == 0 && allVotePhases.length <= 1) {
      return true;
    }

    return false;
  }
}
