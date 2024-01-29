import 'package:mafia_board/data/entity/club_member_entity.dart';
import 'package:mafia_board/domain/model/user_model.dart';

class ClubMemberModel {
  String? id;
  final UserModel user;
  final String clubId;
  final Map<String, double>? winRateByRoleTypeMap;

  ClubMemberModel({
    required this.id,
    required this.user,
    required this.clubId,
    this.winRateByRoleTypeMap,
  });

  ClubMemberModel.fromEntity(ClubMemberEntity? entity)
      : id = entity?.id ?? '',
        user = UserModel.fromEntity(entity?.user),
        clubId = entity?.clubId ?? '',
        winRateByRoleTypeMap = entity?.winRateByRoleTypeMap ?? {};

  ClubMemberModel.empty()
      : id = '',
        user = UserModel.empty(),
        clubId = '',
        winRateByRoleTypeMap = {};

  ClubMemberEntity toEntity() => ClubMemberEntity(
        id: id,
        user: user.toEntity(),
        clubId: clubId,
        winRateByRoleTypeMap: winRateByRoleTypeMap,
      );
}
