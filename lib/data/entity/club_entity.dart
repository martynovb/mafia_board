import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/entity/club_member_entity.dart';

class ClubEntity {
  final String? id;
  String? title;
  String? description;
  final bool? isAdmin;
  double? civilWinRate;
  double? mafWinRate;
  int? createdAt;

  ClubEntity({
    this.id,
    this.title,
    this.description,
    this.isAdmin,
    this.civilWinRate,
    this.mafWinRate,
    this.createdAt,
  });

  ClubEntity.fromFirestoreMap({
    required this.id,
    required this.isAdmin,
    required Map<String, dynamic>? data,
  })  : title = data?[FirestoreKeys.clubTitleFieldKey],
        description = data?[FirestoreKeys.clubDescriptionFieldKey];

  static ClubEntity fromJson(Map<dynamic, dynamic> json) {
    return ClubEntity(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      civilWinRate: json['civilWinRate'] as double?,
      mafWinRate: json['mafWinRate'] as double?,
      createdAt: json['createdAt'] as int?,
    );
  }
}
