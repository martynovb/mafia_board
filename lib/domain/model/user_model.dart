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
}
