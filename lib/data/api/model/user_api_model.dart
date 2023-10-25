class UserApiModel {
  final String? id;
  final String? username;
  final String? email;

  UserApiModel({
    this.id,
    this.username,
    this.email,
  });

  static UserApiModel fromJson(Map<dynamic, dynamic> json) {
    return UserApiModel(
      id: json['id'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
    );
  }
}