import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';

enum PlayerAction {
  playerVoted,
  playerPutOnVote,
  playerSpoke,
  playerWokeUpInNight,
  playerWasChecked,
  playerWasKilled,
}

class PlayerActionViewWrapper {
  final PlayerAction playerAction;
  final DateTime updatedAt;
  final GamePhaseModel gamePhaseModel;

  PlayerActionViewWrapper({
    required this.playerAction,
    required this.updatedAt,
    required this.gamePhaseModel,
  });
}
