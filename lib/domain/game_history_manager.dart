import 'package:mafia_board/data/game_history_repository.dart';
import 'package:mafia_board/data/model/game_history_model.dart';
import 'package:mafia_board/data/model/game_history_type.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:rxdart/subjects.dart';

class GameHistoryManager {
  final GameHistoryRepository repository;

  final BehaviorSubject<List<GameHistoryModel>> _gameHistorySubject =
      BehaviorSubject();

  GameHistoryManager({required this.repository});


  Stream<List<GameHistoryModel>> get gameHistoryStream =>
      _gameHistorySubject.stream;

  void _addRecord(GameHistoryModel model){
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

  void logPlayerSpeech({
    required SpeakPhaseAction speakPhaseAction,
  }) {
    _addRecord(GameHistoryModel(
      text:
          'Speech of player #${speakPhaseAction.player?.id}: ${speakPhaseAction.player?.nickname}',
      type: GameHistoryType.playerSpeech,
      gamePhaseAction: speakPhaseAction,
      createdAt: speakPhaseAction.createdAt,
    ));
  }

  void logVoteFinish({
    required VotePhaseAction votePhaseAction,
  }) {
    final String votedPlayers = votePhaseAction.votedPlayers
        .map((player) => player.nickname)
        .join(', ');
    _addRecord(GameHistoryModel(
      text:
          'Vote against #${votePhaseAction.playerOnVote.id} ${votePhaseAction.playerOnVote.nickname} has finished.\n'
          'Voted ($votedPlayers)',
      type: GameHistoryType.voteFinish,
      gamePhaseAction: votePhaseAction,
      createdAt: votePhaseAction.createdAt,
    ));
  }

  void dispose(){
    _gameHistorySubject.close();
  }
}
