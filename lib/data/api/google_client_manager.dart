import 'package:google_sign_in/google_sign_in.dart';
import 'package:mafia_board/data/entity/google_http_client.dart';
import 'package:mafia_board/data/repo/access_token_provider.dart';

class GoogleClientManager {
  final GoogleSignIn googleSignIn;
  final AccessTokenProvider accessTokenProvider;

  GoogleClientManager({
    required this.googleSignIn,
    required this.accessTokenProvider,
  });

  Future<GoogleHttpClient?> fetchGoogleHttpClient() async {
    var accessToken = await accessTokenProvider.getGoogleAccessToken();
    return GoogleHttpClient({
      'Authorization': accessToken ?? await refreshAccessToken(),
    });
  }

  Future<String> refreshAccessToken() async {
    GoogleSignInAccount? account = await googleSignIn.signInSilently();
    Map<String, String>? authHeaders = await account?.authHeaders;

    if (authHeaders == null) {
      account = await googleSignIn.signIn();
      authHeaders = await account?.authHeaders;
      if (authHeaders != null) {
        accessTokenProvider.setGoogleAccessToken(authHeaders['Authorization']);
      } else {
        accessTokenProvider.cleanGoogleAccessToken();
      }
    }
    return authHeaders?['Authorization'] ?? '';
  }
}
