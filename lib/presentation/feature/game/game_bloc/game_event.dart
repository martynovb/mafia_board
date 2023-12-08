import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/player_model.dart';

abstract class GameEvent {}

class StartGameEvent extends GameEvent {
  final String clubId;

  StartGameEvent(this.clubId);
}

class FinishGameEvent extends GameEvent {
  final String? playerId;
  final FinishGameType finishGameType;

  FinishGameEvent(this.finishGameType, [this.playerId]);
}

class RemoveGameDataEvent extends GameEvent {}
class ResetGameDataEvent extends GameEvent {}

class NextPhaseEvent extends GameEvent {}

class PutOnVoteEvent extends GameEvent {
  final PlayerModel playerOnVote;

  PutOnVoteEvent({
    required this.playerOnVote,
  });
}