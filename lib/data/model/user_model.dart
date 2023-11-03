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

  UserModel.fromApiModel({
    required this.id,
    required this.nickname,
    required this.email,
  });
}
