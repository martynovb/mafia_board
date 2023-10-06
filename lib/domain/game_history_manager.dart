import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/game_history_repository.dart';
import 'package:mafia_board/data/model/game_history_model.dart';
import 'package:mafia_board/data/model/game_history_type.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/speak_phase_status.dart';
import 'package:rxdart/subjects.dart';

class GameHistoryManager {
  final GameHistoryRepository repository;

  final BehaviorSubject<List<GameHistoryModel>> _gameHistorySubject =
      BehaviorSubject();

  GameHistoryManager({required this.repository});

  Stream<List<GameHistoryModel>> get gameHistoryStream =>
      _gameHistorySubject.stream;

  void _addRecord(GameHistoryModel model) {
    repository.add(model);
    _gameHistorySubject.add(repository.getAll());
  }

  void logGameStart({
    required GamePhaseModel gamePhaseModel,
  }) {
    _addRecord(GameHistoryModel(
      text: 'Game Started',
      type: GameHistoryType.startGame,
      createdAt: gamePhaseModel.createdAt,
    ));
  }

  void logGameFinish({
    required GamePhaseModel gamePhaseModel,
  }) {
    _addRecord(GameHistoryModel(
      text: 'Game Finished',
      type: GameHistoryType.finishGame,
      createdAt: gamePhaseModel.createdAt,
    ));
  }

  void logPutOnVote({
    required VotePhaseAction votePhaseAction,
  }) {
    _addRecord(GameHistoryModel(
      text:
          'Player ${votePhaseAction.whoPutOnVote?.nickname} has put player ${votePhaseAction.playerOnVote.nickname} on the vote',
      type: GameHistoryType.putOnVote,
      gamePhaseAction: votePhaseAction,
      createdAt: votePhaseAction.createdAt,
    ));
  }

  void logPlayerSpeech({required SpeakPhaseAction? speakPhaseAction}) {
    if (speakPhaseAction == null) {
      return;
    }
    String text;
    if (speakPhaseAction.isLastWord &&
        speakPhaseAction.status == SpeakPhaseStatus.speaking) {
      text =
          'LAST SPEECH STARTED of player #${speakPhaseAction.player?.playerNumber}: ${speakPhaseAction.player?.nickname}';
    } else if (speakPhaseAction.isLastWord &&
        speakPhaseAction.status == SpeakPhaseStatus.finished) {
      text =
          'LAST SPEECH FINISHED of player #${speakPhaseAction.player?.playerNumber}: ${speakPhaseAction.player?.nickname}';
    } else if (speakPhaseAction.status == SpeakPhaseStatus.speaking) {
      text =
          'SPEECH STARTED of player #${speakPhaseAction.player?.playerNumber}: ${speakPhaseAction.player?.nickname}';
    } else if (speakPhaseAction.status == SpeakPhaseStatus.finished) {
      text =
          'SPEECH FINISHED of player #${speakPhaseAction.player?.playerNumber}: ${speakPhaseAction.player?.nickname}';
    } else {
      return;
    }

    _addRecord(GameHistoryModel(
      text: text,
      type: speakPhaseAction.isLastWord
          ? GameHistoryType.lastWord
          : GameHistoryType.playerSpeech,
      gamePhaseAction: speakPhaseAction,
      createdAt: speakPhaseAction.createdAt,
    ));
  }

  void logVoteFinish({
    required VotePhaseAction votePhaseAction,
  }) {
    String votedPlayers;
    String playersToKick = '';
    if (votePhaseAction.votedPlayers.isNotEmpty) {
      votedPlayers = votePhaseAction.votedPlayers
          .toList()
          .sorted((a, b) => a.id.compareTo(b.id))
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
          'VOTE against #${playersToKick.isEmpty ? ('${votePhaseAction.playerOnVote.playerNumber} ${votePhaseAction.playerOnVote.nickname}') : playersToKick} has finished.', // todo: blood from my eyes
      subText: 'Voted ($votedPlayers)',
      type: GameHistoryType.voteFinish,
      gamePhaseAction: votePhaseAction,
      createdAt: votePhaseAction.createdAt,
    ));
  }

  void logAddFoul({required PlayerModel player}) {
    _addRecord(GameHistoryModel(
      text:
          'FOUL (${player.fouls}/${Constants.maxFouls}) for player #${player.playerNumber}: ${player.nickname}',
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

  void dispose() {
    _gameHistorySubject.close();
  }
}
