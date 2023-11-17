import 'package:mafia_board/data/entity/game/game_history_entity.dart';
import 'package:mafia_board/data/entity/game/game_info_entity.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';

class GameEntity {
  final String? id;
  final String? clubId;
  final List<PlayerEntity> players;
  String? gameStatus;
  String? finishGameType;

  GameEntity({
    required this.id,
    required this.clubId,
    required this.players,
    required this.gameStatus,
    required this.finishGameType,
  });

  static GameEntity fromJson(Map<dynamic, dynamic> json) {
    return GameEntity(
      id: json['id'] as String?,
      clubId: json['clubId'] as String?,
      players: PlayerEntity.parsePlayerEntities(json['players']),
      gameStatus: json['game_status'] as String?,
      finishGameType: json['finish_game_type'] as String?,
    );
  }
}
