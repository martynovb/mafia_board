import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:mafia_board/data/api/api_error_type.dart';

class ErrorHandler {
  Exception handleError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return BadRequestException(ApiErrorType.badRequest);
      case 401:
        return InvalidCredentialsException(ApiErrorType.unauthorized);
      case 403:
        return ForbiddenException(ApiErrorType.forbidden);
      case 404:
        return NotFoundException(ApiErrorType.notFound);
      case 500:
        return ServerException(ApiErrorType.serverError);
      default:
        final responseJson = jsonDecode(responseBody);
        if (responseJson['error'] != null) {
          return ApiException(
            apiErrorType: ApiErrorType.values.firstWhereOrNull(
                  (value) => value == responseJson['error'],
                ) ??
                ApiErrorType.apiError,
            statusCode: statusCode,
          );
        }
        return ApiException(
          apiErrorType: ApiErrorType.apiError,
          statusCode: statusCode,
        );
    }
  }
}

class ApiException implements Exception {
  final ApiErrorType apiErrorType;
  final int statusCode;

  ApiException({required this.apiErrorType, this.statusCode = 0});

  @override
  String toString() => apiErrorType.toString();
}

class BadRequestException extends ApiException {
  BadRequestException(ApiErrorType errorType) : super(apiErrorType: errorType);
}

class ValidationException extends ApiException {
  ValidationException(ApiErrorType errorType) : super(apiErrorType: errorType);
}

class InvalidCredentialsException extends ApiException {
  InvalidCredentialsException(ApiErrorType errorType)
      : super(apiErrorType: errorType);
}

class ForbiddenException extends ApiException {
  ForbiddenException(ApiErrorType errorType) : super(apiErrorType: errorType);
}

class NotFoundException extends ApiException {
  NotFoundException(ApiErrorType errorType) : super(apiErrorType: errorType);
}

class ServerException extends ApiException {
  ServerException(ApiErrorType errorType) : super(apiErrorType: errorType);
}

class ParseException extends ApiException {
  ParseException(ApiErrorType errorType) : super(apiErrorType: errorType);
}
