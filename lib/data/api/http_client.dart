import 'package:http/http.dart' as http;
import 'package:mafia_board/data/api/token_provider.dart';

class HttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final TokenProvider tokenProvider;

  HttpClient({
    required this.baseUrl,
    required this.defaultHeaders,
    required this.tokenProvider,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final newRequest = await _prepareRequest(request);
    final token = tokenProvider.token;
    if (token != null) {
      newRequest.headers['Authorization'] = 'Token $token';
    }
    return _inner.send(newRequest);
  }

  Future<http.Request> _prepareRequest(http.BaseRequest request) async {
    final newUri = Uri.parse(baseUrl + request.url.path);

    final newRequest = http.Request(request.method, newUri)
      ..headers.addAll(request.headers)
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..bodyBytes = await request.finalize().toBytes();

    newRequest.headers.addAll(defaultHeaders);

    return newRequest;
  }
}
