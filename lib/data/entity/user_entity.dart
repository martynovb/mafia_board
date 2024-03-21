import 'package:mafia_board/data/constants/firestore_keys.dart';

class UserEntity {
  final String? id;
  final String? nickname;
  final String? email;

  UserEntity({
    this.id,
    this.nickname,
    this.email,
  });

  UserEntity.fromFirestoreMap({
    required this.id,
    required Map<String, dynamic>? data,
  })  : nickname = data?[FirestoreKeys.nicknameFieldKey],
        email = data?[FirestoreKeys.emailFieldKey];

  static UserEntity fromJson(Map<dynamic, dynamic> json) {
    return UserEntity(
      id: json['id'] as String?,
      nickname: json['nickname'] as String?,
      email: json['email'] as String?,
    );
  }

  static List<UserEntity> parseUserEntities(dynamic data) {
    if (data is! List) {
      return [];
    }
    return data
        .map<UserEntity>((e) => UserEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
