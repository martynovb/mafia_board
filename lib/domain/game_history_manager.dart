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
          'Player ${votePhaseAction.whoPutOnVote.nickname} has put player ${votePhaseAction.playerOnVote.nickname} on the vote',
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
    if (votePhaseAction.votedPlayers.isNotEmpty) {
      final votedPlayersList = votePhaseAction.votedPlayers.toList();
      final sortedVotedPlayersList =
          votedPlayersList.sorted((a, b) => a.id.compareTo(b.id));
      final mappedSortedVotedPlayersList =
          sortedVotedPlayersList.map((player) => player.nickname);
      votedPlayers = mappedSortedVotedPlayersList.join(', ');
    } else {
      votedPlayers = 'No players voted';
    }
    _addRecord(GameHistoryModel(
      text:
          'VOTE against #${votePhaseAction.playerOnVote.playerNumber} ${votePhaseAction.playerOnVote.nickname} has finished.',
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

  void dispose() {
    _gameHistorySubject.close();
  }
}
