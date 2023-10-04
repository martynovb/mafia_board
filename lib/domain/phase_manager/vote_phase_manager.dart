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

  bool canSkipVotePhase(GamePhaseModel phase) {
    final currentVotePhase = phase.getCurrentVotePhase();
    final allVotePhases = phase.getUniqueTodaysVotePhases();
    if (currentVotePhase == null ||
        phase.currentDay == 0 && allVotePhases.length <= 1) {
      return true;
    }

    return false;
  }

  void finishCurrentVotePhase() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final currentVotePhase = phase.getCurrentVotePhase();
    if (currentVotePhase != null) {
      currentVotePhase.isVoted = true;
      phase.updateVotePhase(currentVotePhase);
      updateGamePhase!(phase);
      gameHistoryManager.logVoteFinish(votePhaseAction: currentVotePhase);
      _finishVotePhaseIfPossible(phase);
    }
  }

  bool putOnVote(PlayerModel currentPlayer, PlayerModel playerToVote) {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    if (_isPlayerAlreadyPutOnVote(
          currentPlayer,
          phase.getUniqueTodaysVotePhases(),
        ) &&
        !_isPlayerAlreadyOnVote(
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

  void _finishVotePhaseIfPossible(GamePhaseModel phase) {
    final unvotedPlayers = calculatePlayerVotingStatusMap(phase)
        .entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    //when all players voted even if some vote phases are left
    if (unvotedPlayers.isEmpty) {
      _handlePlayersToKick(phase);
      return;
    }

    var unvotedPhases = phase
        .getUniqueTodaysVotePhases()
        .where((votePhase) => !votePhase.isVoted)
        .toList();

    var allVotePhases = phase.getAllTodaysVotePhases();

    var availablePlayers = boardRepository.getAllAvailablePlayers();

    // when two players on voting and half of players already voted against first
    // automatically put left votes against second
    if (unvotedPhases.length == 1 &&
        allVotePhases.length == 2 &&
        unvotedPlayers.length == availablePlayers.length / 2) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.isVoted = true;
      unvotedPhase.voteList(unvotedPlayers);
      phase.updateVotePhase(unvotedPhase);
      gameHistoryManager.logVoteFinish(votePhaseAction: unvotedPhase);
      updateGamePhase!(phase);
      _handlePlayersToKick(phase);
      return;
    }

    //when only 1 vote phase is left put all left votes against second player
    if (unvotedPhases.length == 1) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.isVoted = true;
      unvotedPhase.voteList(unvotedPlayers);
      phase.updateVotePhase(unvotedPhase);
      gameHistoryManager.logVoteFinish(votePhaseAction: unvotedPhase);
      updateGamePhase!(phase);
      _handlePlayersToKick(phase);
      return;
    }
  }

  bool _isPlayerAlreadyPutOnVote(
    PlayerModel playerModel,
    List<VotePhaseAction> allUniqueTodayVotePhases,
  ) {
    for (var phase in allUniqueTodayVotePhases) {
      if (phase.whoPutOnVote?.id == playerModel.id) {
        return false;
      }
    }
    return true;
  }

  bool _isPlayerAlreadyOnVote(
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

  void _handlePlayersToKick(GamePhaseModel phase) {
    final allGunfightTodayVotePhases = phase.getUniqueTodaysVotePhases();
    // check gunfight vote phases first of all
    final playersToKick = _findPlayersToKick(
      allGunfightTodayVotePhases.isEmpty
          ? phase.getUniqueTodaysVotePhases()
          : allGunfightTodayVotePhases,
    );
    if (playersToKick.isEmpty) {
      return;
    }

    // kick player from the game
    if (playersToKick.length == 1) {
      final speakPhase = SpeakPhaseAction(
        currentDay: phase.currentDay,
        player: playersToKick[0],
        isLastWord: true,
      );
      phase.addSpeakPhase(speakPhase);
      updateGamePhase!(phase);
      return;
    }

    // gunfight
    if (playersToKick.length > 1) {
      for (var player in playersToKick) {
        phase.addSpeakPhase(SpeakPhaseAction(
          currentDay: phase.currentDay,
          player: player,
          timeForSpeakInSec: const Duration(seconds: 30),
        ));
        phase.addVotePhase(VotePhaseAction(
          currentDay: phase.currentDay,
          playerOnVote: player,
          isGunfight: true,
        ));
      }
      gameHistoryManager.logGunfight(players: playersToKick);
      updateGamePhase!(phase);
    }
  }

  List<PlayerModel> _findPlayersToKick(List<VotePhaseAction> allVotePhases) {
    // A Map to keep track of the vote count per player.
    Map<PlayerModel, int> voteCounts = {};

    // Populate the map with vote counts for each player.
    for (var votePhase in allVotePhases) {
      final player = votePhase.playerOnVote;
      if (!voteCounts.containsKey(player)) {
        voteCounts[player] = 0;
      }
      voteCounts[player] = voteCounts[player]! + votePhase.votedPlayers.length;
    }

    // Determine the maximum vote count.
    int maxVotes = 0;
    voteCounts.forEach((player, votes) {
      if (votes > maxVotes) {
        maxVotes = votes;
      }
    });

    // Find all players who have the maximum vote count.
    List<PlayerModel> playersToKick = [];
    voteCounts.forEach((player, votes) {
      if (votes == maxVotes) {
        playersToKick.add(player);
      }
    });

    return playersToKick;
  }

  Map<PlayerModel, bool> calculatePlayerVotingStatusMap(GamePhaseModel phase) {
    List<VotePhaseAction> allTodayVotePhases =
        phase.getUniqueTodaysVotePhases();

    final allAvailablePlayers = boardRepository.getAllAvailablePlayers();
    final Map<PlayerModel, bool> playerVotingStatusMap = {};

    for (var player in allAvailablePlayers) {
      bool playerHasAlreadyVoted = allTodayVotePhases
          .any((votePhase) => votePhase.votedPlayers.contains(player));
      playerVotingStatusMap[player] = playerHasAlreadyVoted;
    }

    return playerVotingStatusMap;
  }
}
