import 'package:mafia_board/data/constants/firestore_keys.dart';

class ClubMemberEntity {
  String? id;
  String? userId;
  String? clubId;
  Map<String, double>? winRateByRoleTypeMap;

  ClubMemberEntity({
    this.id,
    this.userId,
    this.clubId,
    this.winRateByRoleTypeMap,
  });

  Map<dynamic, dynamic> toFirestoreMap() => {
    FirestoreKeys.clubMemberUserIdFieldKey : userId,
    FirestoreKeys.gameClubIdFieldKey : clubId,
  };

  static ClubMemberEntity fromJson(Map<dynamic, dynamic> json) {
    return ClubMemberEntity(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      clubId: json['clubId'] as String?,
      winRateByRoleTypeMap: json['winRateByRoleTypeMap'] as Map<String, double>?,
    );
  }

  static List<ClubMemberEntity> parseUserEntities(dynamic data) {
    if (data is! List) {
      return [];
    }
    return data
        .map<ClubMemberEntity>((e) => ClubMemberEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
