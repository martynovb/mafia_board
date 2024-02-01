import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/user_entity.dart';

class ClubMemberEntity {
  String? id;
  UserEntity? user;
  String? clubId;
  bool isAdmin;
  Map<String, double>? winRateByRoleTypeMap;

  ClubMemberEntity({
    this.id,
    this.user,
    this.isAdmin = false,
    this.clubId,
    this.winRateByRoleTypeMap,
  });

  ClubMemberEntity.fromFirestoreMap({
    required this.id,
    required Map<dynamic, dynamic>? data,
    required this.user,
  })  : clubId = data?[FirestoreKeys.clubIdFieldKey],
        isAdmin = data?[FirestoreKeys.clubMembersIsAdminFieldKey] ?? false;

  Map<String, dynamic> toFirestoreMap() => {
        FirestoreKeys.clubMemberUserIdFieldKey: user?.id,
        FirestoreKeys.clubIdFieldKey: clubId,
        FirestoreKeys.clubMembersIsAdminFieldKey: isAdmin ?? false,
      };

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
