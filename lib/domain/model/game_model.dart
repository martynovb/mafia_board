import 'package:class_to_string/class_to_string.dart';
import 'package:collection/collection.dart';
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

  GameModel({
    required this.id,
    required this.currentDayInfo,
    required this.gameStatus,
    required this.finishGameType,
    required this.startedAt,
    required this.finishedAt,
    required this.createdAt,
    required this.duration,
    required this.winnerType,
  });

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

  static GameModel fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      currentDayInfo: DayInfoModel.fromMap(
          (map['currentDayInfo'] as Map<String, dynamic>?) ?? {}),
      finishGameType: FinishGameType.values
              .firstWhereOrNull((v) => v.name == map['finishGameType']) ??
          FinishGameType.none,
      winnerType: WinnerType.values
              .firstWhereOrNull((v) => v.name == map['winnerType']) ??
          WinnerType.none,
      gameStatus: GameStatus.values
              .firstWhereOrNull((v) => v.name == map['gameStatus']) ??
          GameStatus.none,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['startedAt'] ?? 0),
      finishedAt: DateTime.fromMillisecondsSinceEpoch(map['finishedAt'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      duration: Duration(seconds: map['duration'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'currentDayInfo': currentDayInfo.toMap(),
        'gameStatus': gameStatus.name,
        'finishGameType': finishGameType.name,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'finishedAt': finishedAt.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'duration': duration.inSeconds,
        'winnerType': winnerType.name,
      };

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
