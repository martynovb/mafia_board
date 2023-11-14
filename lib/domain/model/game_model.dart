import 'package:mafia_board/domain/model/game_history_model.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class GameModel {
  final String id;
  final List<DayInfoModel> dayInfoList;
  final List<GameHistoryModel> gameHisotry;
  final List<PlayerModel> players;

  GameModel({
    required this.id,
    required this.dayInfoList,
    required this.gameHisotry,
    required this.players,
  });
}
