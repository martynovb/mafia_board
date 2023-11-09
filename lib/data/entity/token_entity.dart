class TokenEntity {
  final String? token;

  TokenEntity({
    this.token,
  });

  static TokenEntity fromJson(Map<dynamic, dynamic> json) {
    return TokenEntity(
      token: json['auth_token'] as String?,
    );
  }
}
