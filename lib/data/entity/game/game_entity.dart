import 'package:mafia_board/data/entity/game/game_history_entity.dart';
import 'package:mafia_board/data/entity/game/game_info_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';

class GameEntity {
  final String? id;
  final List<DayInfoEntity> dayInfoList;
  final List<GameHistoryEntity> gameHistory;
  final List<PlayerEntity> players;
  final String? gameStatus;

  GameEntity({
    required this.id,
    required this.dayInfoList,
    required this.gameHistory,
    required this.players,
    required this.gameStatus,
  });

  static GameEntity fromJson(Map<dynamic, dynamic> json) {
    return GameEntity(
      id: json['id'] as String?,
      dayInfoList: DayInfoEntity.parseEntities(json['game_info_list']),
      gameHistory: GameHistoryEntity.parseEntities(json['game_history']),
      players: PlayerEntity.parsePlayerEntities(json['players']),
      gameStatus: json['game_status'] as String?,
    );
  }
}
