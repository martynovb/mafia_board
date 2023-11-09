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
}