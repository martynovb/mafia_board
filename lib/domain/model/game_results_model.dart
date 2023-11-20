import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';

class GameResultsModel {
  final WinnerType winnerType;
  final List<PlayerModel> players;
  final bool isPPK;

  GameResultsModel({
    required this.winnerType,
    required this.players,
    required this.isPPK,
  });
}
