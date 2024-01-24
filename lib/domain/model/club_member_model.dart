import 'package:mafia_board/data/entity/club_member_entity.dart';

class ClubMemberModel {
  final String id;
  final String userId;
  final String clubId;
  final Map<String, double>? winRateByRoleTypeMap;

  ClubMemberModel({
    required this.id,
    required this.userId,
    required this.clubId,
    this.winRateByRoleTypeMap,
  });

  ClubMemberModel.fromEntity(ClubMemberEntity? entity)
      : id = entity?.id ?? '',
        userId = entity?.userId ?? '',
        clubId = entity?.clubId ?? '',
        winRateByRoleTypeMap = entity?.winRateByRoleTypeMap ?? {};
}
