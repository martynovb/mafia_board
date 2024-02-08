import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/game_phase/game_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
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

  Map<String, dynamic> toMap() => {
        'game': game?.toMap(),
        'players': players.map((player) => player.toMap()).toList(),
        'dayInfoList': dayInfoList.map((dayInfo) => dayInfo.toMap()).toList(),
        'gamePhases': gamePhases.map((gamePhase) => gamePhase.toMap()).toList(),
      };

  static GameDetailsModel fromMap(Map<String, dynamic> map) {
    return GameDetailsModel(
      game: GameModel.fromMap(map['game'] ?? {}),
      players: PlayerModel.fromListMap(map['players']),
      dayInfoList: DayInfoModel.fromListMap(map['dayInfoList']),
      gamePhases: GamePhaseModel.fromListMap(map['gamePhases']),
    );
  }
}
