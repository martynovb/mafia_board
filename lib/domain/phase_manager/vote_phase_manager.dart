import 'package:collection/collection.dart';
import 'package:mafia_board/data/model/phase_status.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class VotePhaseManager {
  static const _tag = 'VotePhaseManager';
  final GameInfoRepo gameInfoRepo;
  final GamePhaseRepo<VotePhaseAction> voteGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final GameHistoryManager gameHistoryManager;
  final BoardRepo boardRepository;

  VotePhaseManager({
    required this.gameInfoRepo,
    required this.voteGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.gameHistoryManager,
    required this.boardRepository,
  });

  List<VotePhaseAction> getAllPhases(int day) =>
      voteGamePhaseRepo.getAllPhasesByDay(day: day);

  Future<VotePhaseAction?> getCurrentPhase([int? currentDay]) async =>
      voteGamePhaseRepo.getCurrentPhase(
        day: currentDay ?? await gameInfoRepo.getCurrentDay(),
      );

  Future<void> skipVotePhasesIfPossible() async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final currentVotePhase = voteGamePhaseRepo.getCurrentPhase(day: currentDay);
    final allVotePhases = voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);
    final shouldKickAllVotePhase = checkVotePhasesShouldKickAll(allVotePhases);
    if (currentVotePhase != null &&
        currentDay == 1 &&
        allVotePhases.length == 1 &&
        !shouldKickAllVotePhase) {
      // case when its first day and only one player on vote
      MafLogger.d(_tag, 'Remove vote phase');
      voteGamePhaseRepo.remove(gamePhase: currentVotePhase);
    } else if (currentVotePhase != null &&
        currentDay > 1 &&
        allVotePhases.length == 1 &&
        !shouldKickAllVotePhase) {
      // case when only one player on vote
      MafLogger.d(_tag, 'Skip vote phase');
      final votePhase = allVotePhases.first;
      votePhase.status = PhaseStatus.finished;
      voteGamePhaseRepo.update(gamePhase: votePhase);
      await _kickPlayers(
        currentDay: currentDay,
        playersOnVote: [allVotePhases.first.playerOnVote],
      );
    }
  }

  Future<void> finishCurrentVotePhase() async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final currentVotePhase = voteGamePhaseRepo.getCurrentPhase(day: currentDay);
    if (currentVotePhase != null) {
      // workaround to handle last step in gunfight
      currentVotePhase.status = currentVotePhase.shouldKickAllPlayers
          ? currentVotePhase.status
          : PhaseStatus.finished;
      voteGamePhaseRepo.update(gamePhase: currentVotePhase);
      gameHistoryManager.logVoteFinish(votePhaseAction: currentVotePhase);
      await _finishVotePhaseIfPossible();
    }
  }

  Future<bool> putOnVote(PlayerModel playerToVote) async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final currentSpeaker =
        speakGamePhaseRepo.getCurrentPhase(day: currentDay)?.player;
    final allVotePhases = voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);

    if (currentSpeaker != null &&
        (allVotePhases.isEmpty ||
            !_isPlayerAlreadyPutOnVote(
                  currentSpeaker,
                  allVotePhases,
                ) &&
                !_isPlayerAlreadyOnVote(
                  playerToVote,
                  allVotePhases,
                ))) {
      final votePhase = VotePhaseAction(
        currentDay: await gameInfoRepo.getCurrentDay(),
        playerOnVote: playerToVote,
        whoPutOnVote: currentSpeaker,
      );
      voteGamePhaseRepo.add(gamePhase: votePhase);
      gameHistoryManager.logPutOnVote(votePhaseAction: votePhase);
      return true;
    }
    return false;
  }

  Future<bool> voteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final allVotePhases = voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);
    return allVotePhases
            .lastWhereOrNull(
              (phase) => phase.playerOnVote.id == voteAgainstPlayer.id,
            )
            ?.vote(currentPlayer) ??
        false;
  }

  Future<bool> cancelVoteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final allVotePhases = voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);
    return allVotePhases
            .lastWhereOrNull(
              (phase) => phase.playerOnVote.id == voteAgainstPlayer.id,
            )
            ?.removeVote(currentPlayer) ??
        false;
  }

  Future<void> _finishVotePhaseIfPossible() async {
    final currentDay = await gameInfoRepo.getCurrentDay();

    List<VotePhaseAction> allTodayVotePhases =
        voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);

    final List<PlayerModel> unvotedPlayers =
        (await calculatePlayerVotingStatusMap(allTodayVotePhases))
            .entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList();

    // when all players voted
    // even if some vote phases are left
    if (unvotedPlayers.isEmpty) {
      await _handlePlayersToKick(unvotedPlayers.length, allTodayVotePhases);
      return;
    }

    var unvotedPhases = allTodayVotePhases
        .where((votePhase) => votePhase.status != PhaseStatus.finished)
        .toList();

    var availablePlayers = boardRepository.getAllAvailablePlayers();

    // when two players on voting and half of players already voted against first
    // automatically put left votes against second
    if (unvotedPhases.length == 1 &&
        allTodayVotePhases.length == 2 &&
        unvotedPlayers.length == availablePlayers.length / 2) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.status = PhaseStatus.finished;
      unvotedPhase.addVoteList(unvotedPlayers);
      voteGamePhaseRepo.update(gamePhase: unvotedPhase);
      gameHistoryManager.logVoteFinish(votePhaseAction: unvotedPhase);
      await _handlePlayersToKick(unvotedPlayers.length, allTodayVotePhases);
      return;
    }

    if (unvotedPhases.length == 1 && unvotedPhases.first.shouldKickAllPlayers) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.status = PhaseStatus.finished;
      await _handlePlayersToKick(unvotedPlayers.length, allTodayVotePhases);
      return;
    }

    //when only 1 vote phase is left put all left votes against second player
    if (unvotedPhases.length == 1) {
      final unvotedPhase = unvotedPhases.first;
      unvotedPhase.status = PhaseStatus.finished;
      unvotedPhase.addVoteList(unvotedPlayers);
      voteGamePhaseRepo.update(gamePhase: unvotedPhase);
      gameHistoryManager.logVoteFinish(votePhaseAction: unvotedPhase);
      await _handlePlayersToKick(unvotedPlayers.length, allTodayVotePhases);
      return;
    }
  }

  bool _isPlayerAlreadyPutOnVote(
    PlayerModel playerModel,
    List<VotePhaseAction> allUniqueTodayVotePhases,
  ) {
    for (var phase in allUniqueTodayVotePhases) {
      if (phase.whoPutOnVote?.id == playerModel.id) {
        return true;
      }
    }
    return false;
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

  //add votePhases list as param
  Future<void> _handlePlayersToKick(
    int unvotedPlayersCount,
    List<VotePhaseAction> votePhases,
  ) async {
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
      await _kickPlayers(
        currentDay: votesWithMaxVotes.first.currentDay,
        playersOnVote: playersToKick,
      );
      return;
    }

    await _finishAllTodaysUnvotePhases();
    // more then one player with max votes
    await _handleGunfightFlow(
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

  Future<Map<PlayerModel, bool>> calculatePlayerVotingStatusMap([
    List<VotePhaseAction>? allTodayVotePhases,
  ]) async {
    final votePhases = allTodayVotePhases ??
        voteGamePhaseRepo.getAllPhasesByDay(
          day: await gameInfoRepo.getCurrentDay(),
        );
    final allAvailablePlayers = boardRepository.getAllAvailablePlayers();
    final Map<PlayerModel, bool> playerVotingStatusMap = {};

    for (var player in allAvailablePlayers) {
      bool playerHasAlreadyVoted = votePhases
          .any((votePhase) => votePhase.votedPlayers.contains(player));
      playerVotingStatusMap[player] = playerHasAlreadyVoted;
    }

    return playerVotingStatusMap;
  }

  Future<void> _kickPlayers({
    required int currentDay,
    required List<PlayerModel> playersOnVote,
  }) async {
    MafLogger.d(_tag, 'Kick players: ${playersOnVote.toString()}');
    for (var playerModel in playersOnVote) {
      final speakPhase = SpeakPhaseAction(
        currentDay: currentDay,
        player: playerModel,
        isLastWord: true,
      );
      await boardRepository.updatePlayer(playerModel.id, isKicked: true);
      speakGamePhaseRepo.add(gamePhase: speakPhase);
    }
    await _finishAllTodaysUnvotePhases();
    gameHistoryManager.logKickPlayers(players: playersOnVote);
  }

  Future<void> _handleGunfightFlow({
    required List<VotePhaseAction> votePhases,
    required List<PlayerModel> playersToKick,
    required int unvotedPlayersCount,
  }) async {
    final currentDay = await gameInfoRepo.getCurrentDay();
    final areVotePhasesAlreadyGunfighted =
        checkVotePhasesAlreadyGunfighted(votePhases);
    final shouldKickAll = checkVotePhasesShouldKickAll(votePhases);
    // gunfight
    if (!areVotePhasesAlreadyGunfighted) {
      for (var player in playersToKick) {
        speakGamePhaseRepo.add(
            gamePhase: SpeakPhaseAction(
          currentDay: currentDay,
          player: player,
          timeForSpeakInSec: const Duration(seconds: 30),
        ));
        voteGamePhaseRepo.add(
            gamePhase: VotePhaseAction(
          currentDay: currentDay,
          playerOnVote: player,
          isGunfight: true,
        ));
      }
      gameHistoryManager.logGunfight(players: playersToKick);
    } else if (areVotePhasesAlreadyGunfighted && !shouldKickAll) {
      voteGamePhaseRepo.add(
        gamePhase: VotePhaseAction(
          playerOnVote: playersToKick.first,
          currentDay: currentDay,
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
      await _kickPlayers(
        currentDay: currentDay,
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

  Future<void> _finishAllTodaysUnvotePhases() async {
    voteGamePhaseRepo
        .getAllPhasesByDay(day: await gameInfoRepo.getCurrentDay())
        .where(
          (votePhase) =>
              votePhase.status != PhaseStatus.finished &&
              votePhase.votedPlayers.isEmpty,
        )
        .forEach((votePhase) {
      gameHistoryManager.logVoteFinish(votePhaseAction: votePhase);
      votePhase.status = PhaseStatus.finished;
      voteGamePhaseRepo.update(gamePhase: votePhase);
    });
  }
}
