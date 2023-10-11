import 'package:collection/collection.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class VotePhaseManager {
  static const _tag = 'VotePhaseManager';
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

  void skipVotePhasesIfPossible(GamePhaseModel phase) {
    final currentVotePhase = phase.getCurrentVotePhase();
    final allVotePhases = phase.getUniqueTodaysVotePhases();
    final shouldKickAllVotePhase = checkVotePhasesShouldKickAll(allVotePhases);
    if (currentVotePhase != null &&
        phase.currentDay == 1 &&
        allVotePhases.length == 1 &&
        !shouldKickAllVotePhase) {
      // case when its first day and only one player on vote
      MafLogger.d(_tag, 'Remove vote phase');
      phase.removeVotePhase(currentVotePhase);
    } else if (currentVotePhase != null &&
        phase.currentDay > 1 &&
        allVotePhases.length == 1 &&
        !shouldKickAllVotePhase) {
      // case when only one player on vote
      MafLogger.d(_tag, 'Skip vote phase');
      final votePhase = allVotePhases.first;
      votePhase.isVoted = true;
      _kickPlayers(
        phase: phase,
        playersOnVote: [allVotePhases.first.playerOnVote],
      );
    }

    gamePhaseRepository.setCurrentGamePhase(phase);
  }

  void finishCurrentVotePhase() {
    final phase = gamePhaseRepository.getCurrentGamePhase();
    final currentVotePhase = phase.getCurrentVotePhase();
    if (currentVotePhase != null) {
      // workaround to handle last step in gunfight
      currentVotePhase.isVoted =
          currentVotePhase.shouldKickAllPlayers ? false : true;
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
    final List<PlayerModel> unvotedPlayers =
        calculatePlayerVotingStatusMap(phase)
            .entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList();

    // when all players voted
    // even if some vote phases are left
    if (unvotedPlayers.isEmpty) {
      _handlePlayersToKick(phase, unvotedPlayers.length);
      return;
    }

    var unvotedPhases = phase
        .getUniqueTodaysVotePhases()
        .where((votePhase) => !votePhase.isVoted)
        .toList();

    var allVotePhases = phase.getUniqueTodaysVotePhases();
    var availablePlayers = boardRepository.getAllAvailablePlayers();

    // when two players on voting and half of players already voted against first
    // automatically put left votes against second
    if (unvotedPhases.length == 1 &&
        allVotePhases.length == 2 &&
        unvotedPlayers.length == availablePlayers.length / 2) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.isVoted = true;
      unvotedPhase.addVoteList(unvotedPlayers);
      phase.updateVotePhase(unvotedPhase);
      gameHistoryManager.logVoteFinish(votePhaseAction: unvotedPhase);
      updateGamePhase!(phase);
      _handlePlayersToKick(phase, unvotedPlayers.length);
      return;
    }

    if (unvotedPhases.length == 1 && unvotedPhases.first.shouldKickAllPlayers) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.isVoted = true;
      _handlePlayersToKick(phase, unvotedPlayers.length);
      return;
    }

    //when only 1 vote phase is left put all left votes against second player
    if (unvotedPhases.length == 1) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.isVoted = true;
      unvotedPhase.addVoteList(unvotedPlayers);
      phase.updateVotePhase(unvotedPhase);
      gameHistoryManager.logVoteFinish(votePhaseAction: unvotedPhase);
      updateGamePhase!(phase); // remove?
      _handlePlayersToKick(phase, unvotedPlayers.length);
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

  void _handlePlayersToKick(GamePhaseModel phase, int unvotedPlayersCount) {
    final votePhases = phase.getUniqueTodaysVotePhases();
    final votesWithMaxVotes = _findVotePhasesWithMaxVotes(votePhases);
    final playersToKick =
        votesWithMaxVotes.map((votePhase) => votePhase.playerOnVote).toList();

    // no one voted yet
    if (votesWithMaxVotes.isEmpty) {
      return;
    }

    // kick player from the game
    if (votesWithMaxVotes.length == 1 &&
        !votesWithMaxVotes.first.shouldKickAllPlayers) {
      _kickPlayers(
        phase: phase,
        playersOnVote: playersToKick,
      );
      return;
    }

    _finishAllTodaysUnvotePhases(phase);
    // more then one player with max votes
    _handleGunfightFlow(
      phase: phase,
      votePhases: votePhases,
      playersToKick: playersToKick,
      unvotedPlayersCount: unvotedPlayersCount,
    );
  }

  List<VotePhaseAction> _findVotePhasesWithMaxVotes(
    List<VotePhaseAction> allVotePhases,
  ) {
    // A Map to keep track of the vote count per player.
    Map<VotePhaseAction, int> voteCounts = {};

    // Populate the map with vote counts for each player.
    for (var votePhase in allVotePhases) {
      if (!voteCounts.containsKey(votePhase)) {
        voteCounts[votePhase] = 0;
      }
      voteCounts[votePhase] =
          voteCounts[votePhase]! + votePhase.votedPlayers.length;
    }

    // Determine the maximum vote count.
    int maxVotes = 0;
    voteCounts.forEach((player, votes) {
      if (votes > maxVotes) {
        maxVotes = votes;
      }
    });

    // Find all players who have the maximum vote count.
    List<VotePhaseAction> votesWithPlayersToKick = [];
    voteCounts.forEach((player, votes) {
      if (votes == maxVotes) {
        votesWithPlayersToKick.add(player);
      }
    });

    return votesWithPlayersToKick;
  }

  Map<PlayerModel, bool> calculatePlayerVotingStatusMap(GamePhaseModel? phase) {
    if (phase == null) {
      return {};
    }
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

  void _kickPlayers({
    required GamePhaseModel phase,
    required List<PlayerModel> playersOnVote,
  }) {
    for (var playerModel in playersOnVote) {
      final speakPhase = SpeakPhaseAction(
        currentDay: phase.currentDay,
        player: playerModel,
        isLastWord: true,
      );
      boardRepository.updatePlayer(playerModel.id, isKicked: true);
      phase.addSpeakPhase(speakPhase);
    }
    _finishAllTodaysUnvotePhases(phase);
    gameHistoryManager.logKickPlayers(players: playersOnVote);
    updateGamePhase!(phase);
  }

  void _handleGunfightFlow({
    required GamePhaseModel phase,
    required List<VotePhaseAction> votePhases,
    required List<PlayerModel> playersToKick,
    required int unvotedPlayersCount,
  }) {
    final areVotePhasesAlreadyGunfighted =
        checkVotePhasesAlreadyGunfighted(votePhases);
    final shouldKickAll = checkVotePhasesShouldKickAll(votePhases);
    // gunfight
    if (!areVotePhasesAlreadyGunfighted) {
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
    } else if (areVotePhasesAlreadyGunfighted && !shouldKickAll) {
      phase.addVotePhase(
        VotePhaseAction(
          playerOnVote: playersToKick.first,
          currentDay: phase.currentDay,
          isGunfight: true,
          shouldKickAllPlayers: true,
          playersToKick: playersToKick,
        ),
      );
      gameHistoryManager.logGunfight(
          players: playersToKick, shouldKickAll: true);
    } else if (areVotePhasesAlreadyGunfighted &&
        shouldKickAll &&
        unvotedPlayersCount <
            boardRepository.getAllAvailablePlayers().length / 2) {
      // There were gunfight and vote about all players to kick and majority voted to kick
      _kickPlayers(
        phase: phase,
        playersOnVote: votePhases.first.playersToKick,
      );
    }
    // otherwise players are left in the game
  }

  bool checkVotePhasesAlreadyGunfighted(List<VotePhaseAction> votePhases) {
    return votePhases.any((votePhases) => votePhases.isGunfight);
  }

  bool checkVotePhasesShouldKickAll(List<VotePhaseAction> votePhases) {
    return votePhases.any((votePhases) => votePhases.shouldKickAllPlayers);
  }

  void _finishAllTodaysUnvotePhases(GamePhaseModel phase) {
    phase
        .getAllTodaysVotePhases()
        .where(
          (votePhase) => !votePhase.isVoted && votePhase.votedPlayers.isEmpty,
        )
        .forEach((votePhase) {
      gameHistoryManager.logVoteFinish(votePhaseAction: votePhase);
      votePhase.isVoted = true;
    });
  }
}
