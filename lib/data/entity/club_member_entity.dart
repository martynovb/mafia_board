import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/user_entity.dart';

class ClubMemberEntity {
  String? id;
  UserEntity? user;
  String? clubId;
  Map<String, double>? winRateByRoleTypeMap;

  ClubMemberEntity({
    this.id,
    this.user,
    this.clubId,
    this.winRateByRoleTypeMap,
  });

  Map<dynamic, dynamic> toFirestoreMap() => {
        FirestoreKeys.clubMemberUserIdFieldKey: user?.id,
        FirestoreKeys.gameClubIdFieldKey: clubId,
      };

  static ClubMemberEntity fromFirestoreMap({
    required String? id,
    required Map<dynamic, dynamic> json,
    required UserEntity user,
  }) =>
      ClubMemberEntity(
        id: id,
        clubId: json[FirestoreKeys.gameClubIdFieldKey],
        user: user,
      );

  static ClubMemberEntity fromJson(Map<dynamic, dynamic> json) {
    return ClubMemberEntity(
      id: json['id'] as String?,
      user: UserEntity.fromJson(json['user']),
      clubId: json['clubId'] as String?,
      winRateByRoleTypeMap:
          json['winRateByRoleTypeMap'] as Map<String, double>?,
    );
  }

  static List<ClubMemberEntity> parseUserEntities(dynamic data) {
    if (data is! List) {
      return [];
    }
    return data
        .map<ClubMemberEntity>(
            (e) => ClubMemberEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
