import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/entity/game/game_entity.dart';
import 'package:mafia_board/data/entity/game/game_info_entity.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_status.dart';

class GameModel {
  final String id;
  final DayInfoModel currentDayInfo;
  final GameStatus gameStatus;
  final FinishGameType finishGameType;

  GameModel({
    required this.id,
    required this.currentDayInfo,
    required this.gameStatus,
    required this.finishGameType,
  });

  GameModel.fromEntity(
    GameEntity? gameEntity,
    DayInfoEntity? dayInfoEntity,
  )   : id = gameEntity?.id ?? '',
        gameStatus = gameStatusMapper(gameEntity?.gameStatus),
        finishGameType = finishGameTypeMapper(gameEntity?.finishGameType),
        currentDayInfo = DayInfoModel.fromEntity(dayInfoEntity);

  @override
  String toString() {
    return (ClassToString('GameModel')
          ..add('id', id)
          ..add('currentDay', currentDayInfo)
          ..add('createdAt', gameStatus)
          ..add('status', finishGameType))
        .toString();
  }
}
