import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

abstract class GameEvent {}

class StartGameEvent extends GameEvent {}

class FinishGameEvent extends GameEvent {
  final FinishGameType finishGameType;

  FinishGameEvent(this.finishGameType);
}

class NextPhaseEvent extends GameEvent {}

class PutOnVoteEvent extends GameEvent {
  final PlayerModel playerOnVote;

  PutOnVoteEvent({
    required this.playerOnVote,
  });
}
