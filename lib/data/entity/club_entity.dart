import 'package:mafia_board/data/entity/club_member_entity.dart';
import 'package:mafia_board/data/entity/user_entity.dart';

class ClubEntity {
  final String? id;
  String? title;
  String? description;
  String? googleSheetId;
  final List<ClubMemberEntity>? members;
  final List<ClubMemberEntity>? admins;
  String? rulesId;
  double? civilWinRate;
  double? mafWinRate;
  int? createdAt;

  ClubEntity({
    this.id,
    this.title,
    this.description,
    this.members,
    this.admins,
    this.rulesId,
    this.googleSheetId,
    this.civilWinRate,
    this.mafWinRate,
    this.createdAt,
  });

  static ClubEntity fromJson(Map<dynamic, dynamic> json) {
    return ClubEntity(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      rulesId: json['rulesId'] as String?,
      civilWinRate: json['civilWinRate'] as double?,
      mafWinRate: json['mafWinRate'] as double?,
      createdAt: json['createdAt'] as int?,
      members: ClubMemberEntity.parseUserEntities(json['members']),
      admins: ClubMemberEntity.parseUserEntities(json['admins']),
    );
  }
}
