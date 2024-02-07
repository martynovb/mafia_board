import 'package:mafia_board/data/entity/user_entity.dart';

class UserModel {
  final String id;
  final String nickname;
  final String email;

  UserModel({
    required this.id,
    required this.nickname,
    required this.email,
  });

  UserModel.empty()
      : id = '',
        nickname = '',
        email = '';

  UserModel.fromEntity(UserEntity? entity)
      : id = entity?.id ?? '',
        nickname = entity?.nickname ?? '',
        email = entity?.email ?? '';

  UserEntity toEntity() => UserEntity(id: id, nickname: nickname, email: email);

  Map<String, dynamic> toMap() => {
        'id': id,
        'nickname': nickname,
        'email': email,
      };

  static UserModel fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] ?? '',
        nickname: map['nickname'] ?? '',
        email: map['email'] ?? '',
      );
}
