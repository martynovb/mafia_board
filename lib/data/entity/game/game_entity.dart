import 'package:mafia_board/data/constants/firestore_keys.dart';

class GameEntity {
  String? id;
  final String? clubId;
  String? gameStatus;
  String? finishGameType;
  String? winRole;
  int? mafsLeft;
  final int startedInMills;
  int? finishedInMills;

  GameEntity({
    this.id,
    required this.clubId,
    required this.gameStatus,
    required this.finishGameType,
    required this.startedInMills,
  });

  Map<String, dynamic> toFirestoreMap() => {
    FirestoreKeys.clubIdFieldKey : clubId,
    FirestoreKeys.gameFinishTypeFieldKey : finishGameType,
    FirestoreKeys.gameWinRoleFieldKey : winRole,
    FirestoreKeys.gameMafsLeftFieldKey : mafsLeft,
    FirestoreKeys.startedInMillsFieldKey : startedInMills,
    FirestoreKeys.finishedInMillsFieldKey : finishedInMills,
  };
}
