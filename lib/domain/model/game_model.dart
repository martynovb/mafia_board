import 'package:class_to_string/class_to_string.dart';
import 'package:mafia_board/data/entity/game/game_entity.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/winner_type.dart';

class GameModel {
  final String id;
  final DayInfoModel currentDayInfo;
  final GameStatus gameStatus;
  final FinishGameType finishGameType;
  final DateTime startedAt;
  final DateTime finishedAt;
  final DateTime createdAt;
  final Duration duration;
  final WinnerType winnerType;

  GameModel.fromEntity(GameEntity? gameEntity, [DayInfoEntity? dayInfoEntity])
      : id = gameEntity?.id ?? '',
        gameStatus = gameStatusMapper(gameEntity?.gameStatus),
        finishGameType = finishGameTypeMapper(gameEntity?.finishGameType),
        currentDayInfo = DayInfoModel.fromEntity(dayInfoEntity),
        startedAt = DateTime.fromMillisecondsSinceEpoch(
            gameEntity?.startedInMills ?? 0),
        finishedAt = DateTime.fromMillisecondsSinceEpoch(
            gameEntity?.finishedInMills ?? 0),
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(gameEntity?.createdAt ?? 0),
        duration = Duration(
          milliseconds: (gameEntity?.finishedInMills ?? 0) -
              (gameEntity?.startedInMills ?? 0),
        ),
        winnerType = mapWinnerType(gameEntity?.winRole);


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
