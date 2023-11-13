import 'package:mafia_board/data/entity/user_entity.dart';

class ClubEntity {
  final String? id;
  final String? title;
  final String? description;
  final List<UserEntity>? members;
  final List<UserEntity>? admins;
  final List<UserEntity>? waitList;

  ClubEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.members,
    required this.admins,
    required this.waitList,
  });

  static ClubEntity fromJson(Map<dynamic, dynamic> json) {
    return ClubEntity(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      members: UserEntity.parseUserEntities(json['members']),
      admins: UserEntity.parseUserEntities(json['admins']),
      waitList: UserEntity.parseUserEntities(json['waitList']),
    );
  }
}
