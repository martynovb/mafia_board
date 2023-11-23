import 'package:mafia_board/domain/model/player_model.dart';

class PlayerScoreModel {
  PlayerModel player;
  double bestMove;
  double compensation;
  double gamePoints;
  double bonus;
  bool isPPK;
  bool isFirstKilled;

  PlayerScoreModel({
    required this.player,
    this.bestMove = 0,
    this.compensation = 0,
    this.gamePoints = 0,
    this.bonus = 0,
    this.isPPK = false,
    this.isFirstKilled = false,
  });

  double total() => bestMove + compensation + gamePoints + bonus;
}
