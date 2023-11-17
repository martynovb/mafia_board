import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';

class GameResultsModel {
  final WinnerType winnerType;
  final List<PlayerModel> allPlayers;

  GameResultsModel({
    required this.winnerType,
    required this.allPlayers,
  });
}
