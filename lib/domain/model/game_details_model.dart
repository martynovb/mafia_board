import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';

class GameDetailsModel {
  final GameModel? game;
  final List<PlayerModel> players;
  final List<DayInfoModel> dayInfoList;
  final List<GamePhaseModel> gamePhases;

  GameDetailsModel({
    required this.game,
    required this.players,
    required this.dayInfoList,
    required this.gamePhases,
  });

  const GameDetailsModel.empty()
      : game = null,
        players = const [],
        dayInfoList = const [],
        gamePhases = const [];
}
