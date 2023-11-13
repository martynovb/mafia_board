class UserEntity {
  final String? id;
  final String? username;
  final String? email;

  UserEntity({
    this.id,
    this.username,
    this.email,
  });

  static UserEntity fromJson(Map<dynamic, dynamic> json) {
    return UserEntity(
      id: json['id'] as String?,
      username: json['username'] as String?,
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