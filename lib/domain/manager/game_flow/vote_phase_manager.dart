import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/domain/manager/game_history_manager.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';
import 'package:mafia_board/presentation/maf_logger.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

class VotePhaseManager {
  static const _tag = 'VotePhaseManager';
  final GamePhaseRepo<VotePhaseModel> voteGamePhaseRepo;
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;
  final GameHistoryManager gameHistoryManager;
  final PlayersRepo boardRepository;
  final GetCurrentGameUseCase getCurrentGameUseCase;

  final BehaviorSubject<VotePhaseModel?> _currentVoteSubject =
      BehaviorSubject();

  VotePhaseManager({
    required this.voteGamePhaseRepo,
    required this.speakGamePhaseRepo,
    required this.gameHistoryManager,
    required this.boardRepository,
    required this.getCurrentGameUseCase,
  });

  Stream<VotePhaseModel?> get currentVotePhaseStream =>
      _currentVoteSubject.stream;

  Future<List<VotePhaseModel>> getAllTodaysPhases() async {
    final game = await getCurrentGameUseCase.execute();
    final dayInfo = game.currentDayInfo;
    final currentDay = dayInfo.day;
    return voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);
  }

  Future<VotePhaseModel?> getCurrentPhase([int? currentDay]) async {
    final game = await getCurrentGameUseCase.execute();
    return voteGamePhaseRepo.getCurrentPhase(
      day: currentDay ?? game.currentDayInfo.day,
    );
  }

  Future<void> skipVotePhasesIfPossible() async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final currentVotePhase = voteGamePhaseRepo.getCurrentPhase(day: currentDay);
    final allVotePhases = voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);
    final shouldKickAllVotePhase = checkVotePhasesShouldKickAll(allVotePhases);
    if (currentVotePhase != null &&
        currentDay == Constants.firstDay &&
        allVotePhases.length == 1 &&
        !shouldKickAllVotePhase) {
      // case when its first day and only one player on vote
      MafLogger.d(_tag, 'Remove vote phase');
      voteGamePhaseRepo.remove(gamePhase: currentVotePhase);
    } else if (currentVotePhase != null &&
        currentDay > Constants.firstDay &&
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
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
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

  Future<bool> putOnVote(String playerToVoteId) async {
    final game = await getCurrentGameUseCase.execute();
    final dayInfo = game.currentDayInfo;
    final currentDay = dayInfo.day;
    if (dayInfo.currentPhase != PhaseType.speak ||
        speakGamePhaseRepo.getCurrentPhase(day: currentDay)?.isGunfight ==
            true ||
        speakGamePhaseRepo.getCurrentPhase(day: currentDay)?.isLastWord ==
            true) {
      return false;
    }
    final playerToVote =
        await boardRepository.getPlayerByTempId(playerToVoteId);
    final currentSpeakerId =
        speakGamePhaseRepo.getCurrentPhase(day: currentDay)?.playerTempId;
    if (currentSpeakerId == null ||
        playerToVote == null ||
        !playerToVote.isInGame()) {
      return false;
    }

    final currentSpeaker =
        await boardRepository.getPlayerByTempId(currentSpeakerId);
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
      final votePhase = VotePhaseModel(
        tempId: const Uuid().v1(),
        currentDay: currentDay,
        playerOnVote: playerToVote,
        whoPutOnVote: currentSpeaker, playersToKick: [], votedPlayers: {},
      );
      _currentVoteSubject.add(votePhase);
      await voteGamePhaseRepo.add(gamePhase: votePhase);
      gameHistoryManager.logPutOnVote(votePhaseAction: votePhase);
      return true;
    }
    return false;
  }

  Future<bool> revokePutOnVote(PlayerModel player) async {
    final game = await getCurrentGameUseCase.execute();
    final dayInfo = game.currentDayInfo;
    final currentDay = dayInfo.day;
    final votePhaseWithThisPlayer =
        voteGamePhaseRepo.getAllPhasesByDay(day: currentDay).firstWhereOrNull(
              (votePhase) => votePhase.playerOnVote.tempId == player.tempId,
            );
    if (votePhaseWithThisPlayer == null) {
      return false;
    }
    voteGamePhaseRepo.remove(gamePhase: votePhaseWithThisPlayer);
    gameHistoryManager.removePutOnVoteLog(
        votePhaseAction: votePhaseWithThisPlayer);
    _currentVoteSubject.add(voteGamePhaseRepo.getLastPhase());
    return true;
  }

  Future<bool> voteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) async {
    if (!currentPlayer.isInGame()) {
      return false;
    }
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final allVotePhases = voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);
    return allVotePhases
            .lastWhereOrNull(
              (phase) => phase.playerOnVote.tempId == voteAgainstPlayer.tempId,
            )
            ?.vote(currentPlayer) ??
        false;
  }

  Future<bool> cancelVoteAgainst({
    required PlayerModel currentPlayer,
    required PlayerModel voteAgainstPlayer,
  }) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final allVotePhases = voteGamePhaseRepo.getAllPhasesByDay(day: currentDay);
    return allVotePhases
            .lastWhereOrNull(
              (phase) => phase.playerOnVote.tempId == voteAgainstPlayer.tempId,
            )
            ?.removeVote(currentPlayer) ??
        false;
  }

  Future<void> _finishVotePhaseIfPossible() async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;

    List<VotePhaseModel> allTodayVotePhases =
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
    List<VotePhaseModel> allUniqueTodayVotePhases,
  ) {
    for (var phase in allUniqueTodayVotePhases) {
      if (phase.whoPutOnVote?.tempId == playerModel.tempId) {
        return true;
      }
    }
    return false;
  }

  bool _isPlayerAlreadyOnVote(
    PlayerModel playerModel,
    List<VotePhaseModel> allUniqueTodayVotePhases,
  ) {
    for (var phase in allUniqueTodayVotePhases) {
      if (phase.playerOnVote.tempId == playerModel.tempId) {
        return true;
      }
    }
    return false;
  }

  //add votePhases list as param
  Future<void> _handlePlayersToKick(
    int unvotedPlayersCount,
    List<VotePhaseModel> votePhases,
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

  List<VotePhaseModel> _findVotePhasesWithMaxVotes(
    List<VotePhaseModel> allVotePhases,
  ) {
    // A Map to keep track of the vote count per player.
    Map<VotePhaseModel, int> voteCounts = {};

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
    List<VotePhaseModel> votesWithPlayersToKick = [];
    voteCounts.forEach((player, votes) {
      if (votes == maxVotes) {
        votesWithPlayersToKick.add(player);
      }
    });

    return votesWithPlayersToKick;
  }

  Future<Map<PlayerModel, bool>> calculatePlayerVotingStatusMap([
    List<VotePhaseModel>? allTodayVotePhases,
  ]) async {
    final game = await getCurrentGameUseCase.execute();
    final votePhases = allTodayVotePhases ??
        voteGamePhaseRepo.getAllPhasesByDay(
          day: game.currentDayInfo.day,
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
      final speakPhase = SpeakPhaseModel(
        tempId: const Uuid().v1(),
        currentDay: currentDay,
        playerTempId: playerModel.tempId,
        isLastWord: true,
      );
      await boardRepository.updatePlayer(playerModel.tempId, isKicked: true);
      await speakGamePhaseRepo.add(gamePhase: speakPhase);
    }
    await _finishAllTodaysUnvotePhases();
    gameHistoryManager.logKickPlayers(players: playersOnVote);
  }

  Future<void> _handleGunfightFlow({
    required List<VotePhaseModel> votePhases,
    required List<PlayerModel> playersToKick,
    required int unvotedPlayersCount,
  }) async {
    final game = await getCurrentGameUseCase.execute();
    final currentDay = game.currentDayInfo.day;
    final areVotePhasesAlreadyGunfighted =
        checkVotePhasesAlreadyGunfighted(votePhases);
    final shouldKickAll = checkVotePhasesShouldKickAll(votePhases);
    // gunfight
    if (!areVotePhasesAlreadyGunfighted) {
      for (var player in playersToKick) {
        await speakGamePhaseRepo.add(
            gamePhase: SpeakPhaseModel(
          tempId: const Uuid().v1(),
          currentDay: currentDay,
          playerTempId: player.tempId,
          timeForSpeakInSec: Constants.gunfightTimeForSpeak,
          isGunfight: true,
        ));
        await voteGamePhaseRepo.add(
            gamePhase: VotePhaseModel(
          tempId: const Uuid().v1(),
          currentDay: currentDay,
          playerOnVote: player,
          isGunfight: true, playersToKick: [], votedPlayers: {},
        ));
      }
      gameHistoryManager.logGunfight(players: playersToKick);
    } else if (areVotePhasesAlreadyGunfighted && !shouldKickAll) {
      await voteGamePhaseRepo.add(
        gamePhase: VotePhaseModel(
          tempId: const Uuid().v1(),
          playerOnVote: playersToKick.first,
          currentDay: currentDay,
          isGunfight: true,
          shouldKickAllPlayers: true,
          playersToKick: playersToKick, votedPlayers: {},
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

  bool checkVotePhasesAlreadyGunfighted(List<VotePhaseModel> votePhases) {
    return votePhases.any((votePhases) => votePhases.isGunfight);
  }

  bool checkVotePhasesShouldKickAll(List<VotePhaseModel> votePhases) {
    return votePhases.any((votePhases) => votePhases.shouldKickAllPlayers);
  }

  Future<void> _finishAllTodaysUnvotePhases() async {
    final game = await getCurrentGameUseCase.execute();
    voteGamePhaseRepo
        .getAllPhasesByDay(day: game.currentDayInfo.day)
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

  void reset() {
    _currentVoteSubject.add(null);
  }
}
