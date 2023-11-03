import 'package:mafia_board/data/model/game_history_model.dart';
import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/model/player_model.dart';

class GameModel {
  final String id;
  final List<GameInfoModel> gameInfoList;
  final List<GameHistoryModel> gameHisotry;
  final List<PlayerModel> players;

  GameModel({
    required this.id,
    required this.gameInfoList,
    required this.gameHisotry,
    required this.players,
  });
}
