import 'package:mafia_board/data/entity/game/game_entity.dart';
import 'package:mafia_board/data/entity/game/game_info_entity.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_status.dart';

class GameModel {
  final String id;
  final DayInfoModel currentDayInfo;
  final GameStatus gameStatus;

  GameModel({
    required this.id,
    required this.currentDayInfo,
    required this.gameStatus,
  });

  GameModel.fromEntity(
    GameEntity? gameEntity,
    DayInfoEntity? dayInfoEntity,
  )   : id = gameEntity?.id ?? '',
        gameStatus = gameStatusMapper(gameEntity?.gameStatus),
        currentDayInfo = DayInfoModel.fromEntity(dayInfoEntity);
}
