import 'package:mafia_board/domain/field_validation/field_type.dart';
import 'package:mafia_board/domain/field_validation/validation_error_code.dart';

class BaseException implements Exception {
  final String errorMessage;

  BaseException(this.errorMessage);
}

class ValidationError extends BaseException {
  final FieldType fieldType;
  final ValidationErrorCode errorCode;

  ValidationError({
    required this.fieldType,
    required this.errorCode,
    required String errorMessage,
  }) : super(errorMessage);
}

class ValidationErrorsMap extends BaseException {
  final Map<FieldType, ValidationError> errorMap;

  ValidationErrorsMap({
    required this.errorMap,
  }) : super('Validation error');
}

class InvalidPlayerDataException implements Exception {
  final String errorMessage;

  InvalidPlayerDataException(this.errorMessage);
}
