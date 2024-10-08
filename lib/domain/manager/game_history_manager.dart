import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/constants.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/history/history_repository.dart';
import 'package:mafia_board/domain/model/game_history_model.dart';
import 'package:mafia_board/domain/model/game_history_type.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/phase_status.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:rxdart/subjects.dart';

class GameHistoryManager {
  final HistoryRepo repository;
  final PlayersRepo boardRepo;

  final BehaviorSubject<List<GameHistoryModel>> _gameHistorySubject =
      BehaviorSubject();

  GameHistoryManager({
    required this.repository,
    required this.boardRepo,
  });

  Stream<List<GameHistoryModel>> get gameHistoryStream =>
      _gameHistorySubject.stream;

  void _addRecord(GameHistoryModel model) {
    repository.add(model);
    _gameHistorySubject.add(repository.getAll());
  }

  void _notifyListeners() {
    _gameHistorySubject.add(repository.getAll());
  }

  void logGameStart({
    required DayInfoModel dayInfo,
  }) {
    _addRecord(GameHistoryModel(
      text: 'Game Started',
      type: GameHistoryType.startGame,
      createdAt: dayInfo.createdAt,
    ));
  }

  void logGameFinish({
    required DayInfoModel dayInfo,
  }) {
    _addRecord(GameHistoryModel(
      text: 'Game Finished',
      type: GameHistoryType.finishGame,
      createdAt: dayInfo.createdAt,
    ));
  }

  void logPutOnVote({
    required VotePhaseModel votePhaseAction,
  }) {
    _addRecord(GameHistoryModel(
      text:
          'Player ${votePhaseAction.whoPutOnVote?.nickname} has put player ${votePhaseAction.playerOnVote.nickname} on the vote',
      type: GameHistoryType.putOnVote,
      gamePhaseAction: votePhaseAction,
      createdAt: votePhaseAction.updatedAt,
    ));
  }

  void removePutOnVoteLog({
    required VotePhaseModel votePhaseAction,
  }) {
    repository
        .deleteWhere((model) => model.gamePhaseAction == votePhaseAction);
    _notifyListeners();
  }

  Future<void> logPlayerSpeech(
      {required SpeakPhaseModel speakPhaseAction}) async {
    final speakerId = speakPhaseAction.playerTempId;
    if (speakerId == null) {
      return;
    }
    final speaker = await boardRepo.getPlayerByTempId(speakerId);
    String text;
    String subText = '';
    if (speakPhaseAction.isLastWord &&
        speakPhaseAction.status == PhaseStatus.inProgress) {
      text =
          'LAST SPEECH STARTED of player #${speaker?.seatNumber}: ${speaker?.nickname}';
    } else if (speakPhaseAction.isLastWord &&
        speakPhaseAction.status == PhaseStatus.finished) {
      text =
          'LAST SPEECH FINISHED of player #${speaker?.seatNumber}: ${speaker?.nickname}';
      subText = speakPhaseAction.bestMove.isEmpty
          ? ''
          : 'Best move: ${speakPhaseAction.bestMove.map((player) => player.seatNumber).join(', ')}';
    } else if (speakPhaseAction.status == PhaseStatus.inProgress) {
      text =
          'SPEECH STARTED of player #${speaker?.seatNumber}: ${speaker?.nickname}';
    } else if (speakPhaseAction.status == PhaseStatus.finished) {
      text =
          'SPEECH FINISHED of player #${speaker?.seatNumber}: ${speaker?.nickname}';
    } else {
      return;
    }

    _addRecord(GameHistoryModel(
      text: text,
      subText: subText,
      type: speakPhaseAction.isLastWord
          ? GameHistoryType.lastWord
          : GameHistoryType.playerSpeech,
      gamePhaseAction: speakPhaseAction,
      createdAt: speakPhaseAction.updatedAt,
    ));
  }

  void logVoteFinish({
    required VotePhaseModel votePhaseAction,
  }) {
    String votedPlayers;
    String playersToKick = '';
    if (votePhaseAction.votedPlayers.isNotEmpty) {
      votedPlayers = votePhaseAction.votedPlayers
          .toList()
          .sorted((a, b) => a.tempId.compareTo(b.tempId))
          .map((player) => player.nickname)
          .join(', ');
    } else {
      votedPlayers = 'No players voted';
    }

    if (votePhaseAction.shouldKickAllPlayers) {
      playersToKick = votePhaseAction.playersToKick
          .map((player) => player.nickname)
          .join(', ');
    }

    _addRecord(GameHistoryModel(
      text:
          'VOTE against #${playersToKick.isEmpty ? ('${votePhaseAction.playerOnVote.seatNumber} ${votePhaseAction.playerOnVote.nickname}') : playersToKick} has finished.',
      // todo: blood from my eyes
      subText: 'Voted ($votedPlayers)',
      type: GameHistoryType.voteFinish,
      gamePhaseAction: votePhaseAction,
      createdAt: votePhaseAction.updatedAt,
    ));
  }

  void logAddFoul({required PlayerModel player}) {
    _addRecord(GameHistoryModel(
      text:
          'FOUL (${player.fouls}/${Constants.maxFouls}) for player #${player.seatNumber}: ${player.nickname}',
      type: GameHistoryType.playerSpeech,
      createdAt: DateTime.now(),
    ));
  }

  void logGunfight(
      {required List<PlayerModel> players, bool shouldKickAll = false}) {
    String gunfightInfo;
    if (players.isNotEmpty) {
      gunfightInfo = players.map((player) => player.nickname).join(', ');
    } else {
      gunfightInfo = 'No players on gunfight';
    }
    _addRecord(GameHistoryModel(
      text: shouldKickAll ? 'SHOULD KICK ALL?' : 'GUNFIGHT',
      subText: gunfightInfo,
      type: GameHistoryType.voteFinish,
      createdAt: DateTime.now(),
    ));
  }

  void logKickPlayers({required List<PlayerModel> players}) {
    String gunfightInfo;
    if (players.isNotEmpty) {
      gunfightInfo = players.map((player) => player.nickname).join(', ');
    } else {
      gunfightInfo = 'No players on gunfight';
    }
    _addRecord(GameHistoryModel(
      text: 'KICK PLAYER${players.length <= 1 ? '' : 'S'} FROM THE GAME',
      subText: gunfightInfo,
      type: GameHistoryType.kick,
      createdAt: DateTime.now(),
    ));
  }

  void logCheckPlayer({required NightPhaseModel nightPhaseAction}) {
    final title = nightPhaseAction.checkedPlayer == null
        ? 'No one has been checked'
        : '${nightPhaseAction.role.name} (${nightPhaseAction.playersForWakeUp.firstOrNull?.nickname}) CHECKED ${nightPhaseAction.checkedPlayer?.nickname} - ${nightPhaseAction.checkedPlayer?.role.name}';
    var type = GameHistoryType.none;
    if (nightPhaseAction.role == Role.don) {
      type = GameHistoryType.donCheck;
    } else if (nightPhaseAction.role == Role.sheriff) {
      type = GameHistoryType.sheriffCheck;
    }

    _addRecord(GameHistoryModel(
      text: title,
      type: type,
      gamePhaseAction: nightPhaseAction,
      createdAt: DateTime.now(),
    ));
  }

  void removeLogCheckPlayer({required NightPhaseModel nightPhaseAction}) {
    repository
        .deleteWhere((model) => model.gamePhaseAction == nightPhaseAction);
    _notifyListeners();
  }

  void logKillPlayer(
      {PlayerModel? player, NightPhaseModel? nightPhaseAction}) {
    _addRecord(GameHistoryModel(
      text: player == null ? 'MISS' : 'KILL ${player.nickname}',
      subText: player?.role.name ?? '',
      type: player == null ? GameHistoryType.miss : GameHistoryType.kill,
      gamePhaseAction: nightPhaseAction,
      createdAt: DateTime.now(),
    ));
  }

  void removeLogKillPlayer({required NightPhaseModel? nightPhaseAction}) {
    repository
        .deleteWhere((model) => model.gamePhaseAction == nightPhaseAction);
    _notifyListeners();
  }

  void dispose() {
    _gameHistorySubject.close();
  }

  void logNewDay(int day) {
    _addRecord(GameHistoryModel(
      text: 'NEW DAY #$day',
      subText: '***************',
      type: GameHistoryType.newDay,
      createdAt: DateTime.now(),
    ));
  }

  void reset() {
    _gameHistorySubject.add([]);
  }
}
