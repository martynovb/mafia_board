import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/club_member_entity.dart';

class PlayerEntity {
  String? id;

  // pre id for each player.
  // we save players only when game is finished but we need some ids to manage game flow
  // send to firestore to watch game history
  final String? tempId;
  String? gameId;
  final ClubMemberEntity? clubMember;
  final int? fouls;
  final String? role;
  final bool? isRemoved;
  final bool? isKilled;
  final bool? isMuted;
  final bool? isKicked;
  final bool? isPPK;
  final int? seatNumber;

  final double? bestMove;
  final double? compensation;
  final double? gamePoints;
  final double? bonus;
  final bool? isFirstKilled;

  PlayerEntity({
    this.id,
    this.tempId,
    this.gameId,
    required this.clubMember,
    required this.role,
    required this.seatNumber,
    required this.fouls,
    required this.isRemoved,
    required this.isKilled,
    required this.isMuted,
    required this.isKicked,
    required this.isPPK,
    required this.bestMove,
    required this.compensation,
    required this.gamePoints,
    required this.bonus,
    required this.isFirstKilled,
  });

  static PlayerEntity fromJson(Map<dynamic, dynamic> json) {
    return PlayerEntity(
      id: json['id'] as String?,
      tempId: json['tempId'] as String?,
      gameId: json['gameId'] as String?,
      clubMember: ClubMemberEntity.fromJson(json['club_member']),
      role: json['role'] as String?,
      fouls: json['fouls'] as int?,
      isRemoved: json['isRemoved'] as bool?,
      isKilled: json['isKilled'] as bool?,
      isMuted: json['isMuted'] as bool?,
      isKicked: json['isKicked'] as bool?,
      isPPK: json['isPPK'] as bool?,
      seatNumber: json['seatNumber'] as int?,
      bestMove: json['bestMove'] as double?,
      compensation: json['compensation'] as double?,
      gamePoints: json['gamePoints'] as double?,
      bonus: json['bonus'] as double?,
      isFirstKilled: json['isFirstKilled'] as bool?,
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        FirestoreKeys.tempIdFieldKey: tempId,
        FirestoreKeys.gameIdFieldKey: gameId,
        FirestoreKeys.clubMemberIdFieldKey: clubMember?.id,
        FirestoreKeys.foulsFieldKey: fouls,
        FirestoreKeys.roleFieldKey: role,
        FirestoreKeys.isRemovedFieldKey: isRemoved,
        FirestoreKeys.isPpkFieldKey: isPPK,
        FirestoreKeys.seatNumberFieldKey: seatNumber,
        FirestoreKeys.bestMoveFieldKey: bestMove,
        FirestoreKeys.compensationFieldKey: compensation,
        FirestoreKeys.gamePointsFieldKey: gamePoints,
        FirestoreKeys.bonusPointsFieldKey: bonus,
      };

  PlayerEntity.fromFirestoreMap({
    required this.id,
    this.clubMember,
    required Map<String, dynamic> data,
  })  : tempId = data[FirestoreKeys.tempIdFieldKey],
        gameId = data[FirestoreKeys.gameIdFieldKey],
        fouls = data[FirestoreKeys.foulsFieldKey],
        role = data[FirestoreKeys.roleFieldKey],
        isRemoved = data[FirestoreKeys.isRemovedFieldKey],
        isPPK = data[FirestoreKeys.isPpkFieldKey],
        seatNumber = data[FirestoreKeys.seatNumberFieldKey],
        bestMove = data[FirestoreKeys.bestMoveFieldKey],
        compensation = data[FirestoreKeys.compensationFieldKey],
        gamePoints = data[FirestoreKeys.gamePointsFieldKey],
        bonus = data[FirestoreKeys.bonusPointsFieldKey],
        isFirstKilled = null,
        isKicked = null,
        isKilled = null,
        isMuted = null;

  static List<PlayerEntity> parsePlayerEntities(dynamic data) {
    if (data is! List) {
      return [];
    }
    return data
        .map<PlayerEntity>(
            (e) => PlayerEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
