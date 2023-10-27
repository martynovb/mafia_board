import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/api/http_client.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class NetworkManager {
  static const String _tag = 'NetworkManager';

  final HttpClient httpClient;
  final ErrorHandler errorHandler;

  NetworkManager({
    required this.httpClient,
    required this.errorHandler,
  });

  Future<dynamic> get(String path) async {
    MafLogger.d(_tag, 'GET: $path');
    return _requestWrapper(() => httpClient.get(Uri.parse(path)));
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    MafLogger.d(_tag, 'POST: $path');
    body ?? MafLogger.d(_tag, 'body: $body');
    return _requestWrapper(() => httpClient.post(
          Uri.parse(path),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> _requestWrapper<T>(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      MafLogger.d(_tag, 'RESPONSE statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 204) {
        return null;
      } else {
        throw errorHandler.handleError(response.statusCode, response.body);
      }
    } catch (e) {
      MafLogger.e(_tag, e.toString());
      if (e is ApiException) {
        rethrow;
      } else if (e is FormatException) {
        throw ParseException('Failed to parse the response from the server.');
      } else {
        throw ApiException('An unexpected error occurred: $e');
      }
    }
  }
}
