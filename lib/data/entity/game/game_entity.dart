import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/domain/model/game_status.dart';

class GameEntity {
  String? id;
  final String? clubId;
  String? gameStatus;
  String? finishGameType;
  String? winRole;
  int? mafsLeft;
  final int startedInMills;
  int? finishedInMills;
  int? createdAt;

  GameEntity({
    this.id,
    required this.clubId,
    required this.gameStatus,
    required this.finishGameType,
    required this.startedInMills,
  });

  GameEntity.fromFirestoreMap(
      {required this.id, required Map<String, dynamic>? data})
      : clubId = data?[FirestoreKeys.clubIdFieldKey],
        finishGameType = data?[FirestoreKeys.gameFinishTypeFieldKey],
        finishedInMills = data?[FirestoreKeys.finishedInMillsFieldKey],
        startedInMills = data?[FirestoreKeys.startedInMillsFieldKey],
        mafsLeft = data?[FirestoreKeys.gameMafsLeftFieldKey],
        winRole = data?[FirestoreKeys.gameWinRoleFieldKey],
        createdAt = data?[FirestoreKeys.createdAtFieldKey],
        gameStatus = GameStatus.finished.name;

  Map<String, dynamic> toFirestoreMap() => {
        FirestoreKeys.clubIdFieldKey: clubId,
        FirestoreKeys.gameFinishTypeFieldKey: finishGameType,
        FirestoreKeys.gameWinRoleFieldKey: winRole,
        FirestoreKeys.gameMafsLeftFieldKey: mafsLeft,
        FirestoreKeys.startedInMillsFieldKey: startedInMills,
        FirestoreKeys.finishedInMillsFieldKey: finishedInMills,
      };
}
