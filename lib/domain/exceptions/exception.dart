import 'package:mafia_board/domain/exceptions/error_type.dart';
import 'package:mafia_board/domain/field_validation/field_type.dart';
import 'package:mafia_board/domain/field_validation/validation_error_code.dart';

class BaseException implements Exception {
  final ErrorType errorType;
  final String errorMessage;

  BaseException({
    this.errorMessage = '',
    this.errorType = ErrorType.none,
  });
}

class ValidationError extends BaseException {
  final FieldType fieldType;
  final ValidationErrorCode errorCode;

  ValidationError({
    required this.fieldType,
    required super.errorMessage,
    required this.errorCode,
  }) : super(
          errorType: ErrorType.validation,
        );
}

class ValidationErrorsMap extends BaseException {
  final Map<FieldType, ValidationError> errorMap;

  ValidationErrorsMap({
    required this.errorMap,
  }) : super(
          errorType: ErrorType.validation,
        );
}

class InvalidPlayerDataException extends BaseException {
  InvalidPlayerDataException({
    required super.errorMessage,
    required super.errorType,
  });
}

class InvalidGameDataError extends BaseException {
  InvalidGameDataError({
    super.errorMessage,
    errorType = ErrorType.invalidGameData,
  });
}

class InvalidDataError extends BaseException {
  InvalidDataError({
    super.errorMessage,
    errorType = ErrorType.invalidData,
  });
}
