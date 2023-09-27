import 'package:mafia_board/data/model/player_model.dart';

class PlayerHistoryModel {
  final PlayerModel player;
  final Map<int, List<PlayerModel>> voteMap = {};

  PlayerHistoryModel(this.player);


}