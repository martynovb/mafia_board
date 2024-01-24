import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/game/player_entity.dart';

class GameEntity {
  final String? id;
  final String? clubId;
  final List<PlayerEntity>? players;
  String? gameStatus;
  String? finishGameType;

  GameEntity({
    this.id,
    required this.clubId,
    this.players,
    required this.gameStatus,
    required this.finishGameType,
  });

  Map<dynamic, dynamic> toFirestoreMap() => {
    FirestoreKeys.gameClubIdFieldKey : clubId,
    FirestoreKeys.gamePlayersIdsFieldKey : players?.map((player) => player.id),
    FirestoreKeys.gameFinishTypeFieldKey : finishGameType,
  };
}
