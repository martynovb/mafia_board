import 'package:mafia_board/data/model/player_model.dart';

abstract class GameEvent {}

class StartGameEvent extends GameEvent {}

class FinishGameEvent extends GameEvent {}

class NextPhaseEvent extends GameEvent {}

class PutOnVoteEvent extends GameEvent {
  final PlayerModel playerOnVote;

  PutOnVoteEvent({
    required this.playerOnVote,
  });
}
