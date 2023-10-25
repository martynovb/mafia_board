class TokenApiModel {
  final String? token;

  TokenApiModel({
    this.token,
  });

  static TokenApiModel fromJson(Map<dynamic, dynamic> json) {
    return TokenApiModel(
      token: json['auth_token'] as String?,
    );
  }
}
