import 'package:mafia_board/domain/model/player_model.dart';

abstract class VotePhaseEvent {}

class VoteAgainstEvent extends VotePhaseEvent {
  final PlayerModel currentPlayer;
  final PlayerModel voteAgainstPlayer;

  VoteAgainstEvent({
    required this.currentPlayer,
    required this.voteAgainstPlayer,
  });
}

class CancelVoteAgainstEvent extends VotePhaseEvent {
  final PlayerModel currentPlayer;
  final PlayerModel voteAgainstPlayer;

  CancelVoteAgainstEvent({
    required this.currentPlayer,
    required this.voteAgainstPlayer,
  });
}

class FinishVoteAgainstEvent extends VotePhaseEvent {
  final PlayerModel? playerOnVoting;

  FinishVoteAgainstEvent({
    required this.playerOnVoting,
  });
}

class GetVotingDataEvent extends VotePhaseEvent {}
