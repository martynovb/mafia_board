import 'package:mafia_board/data/model/player_model.dart';

abstract class BoardEvent {}

class StartGameEvent extends BoardEvent {}

class NextPhaseEvent extends BoardEvent {}

class PutOnVoteEvent extends BoardEvent {
  final PlayerModel playerOnVote;

  PutOnVoteEvent({
    required this.playerOnVote,
  });
}
