import 'dart:convert';

import 'package:mafia_board/data/api/token_provider.dart';

class ErrorHandler {
  final TokenProvider tokenProvider;

  ErrorHandler({required this.tokenProvider});

  Exception handleError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return BadRequestException('Bad request');
      case 401:
        tokenProvider.deleteToken();
        return InvalidCredentialsException('Unauthorized');
      case 403:
        return ForbiddenException('Forbidden');
      case 404:
        return NotFoundException('Resource not found');
      case 500:
        return ServerException('Server error');
      default:
        final responseJson = jsonDecode(responseBody);
        if (responseJson['error'] != null) {
          return ApiException(responseJson['error']);
        }
        return ApiException('Request failed with status: $statusCode');
    }
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class InvalidCredentialsException extends ApiException {
  InvalidCredentialsException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class ParseException extends ApiException {
  ParseException(String message) : super(message);
}
