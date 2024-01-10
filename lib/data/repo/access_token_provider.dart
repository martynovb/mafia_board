import 'package:shared_preferences/shared_preferences.dart';

class AccessTokenProvider {
  static const String _googleAccessTokenKey = '_googleAccessTokenKey';
  final SharedPreferences prefs;

  AccessTokenProvider(this.prefs);

  Future<String?> getGoogleAccessToken() async {
    return prefs.getString(_googleAccessTokenKey);
  }

  Future<void> setGoogleAccessToken(String? googleAccessToken) async {
    if(googleAccessToken == null){
      return;
    }
    await prefs.setString(_googleAccessTokenKey, googleAccessToken);
  }

  Future<void> cleanGoogleAccessToken() async {
    await prefs.remove(_googleAccessTokenKey);
  }
}