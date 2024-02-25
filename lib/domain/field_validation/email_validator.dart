import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/field_validation/field_type.dart';
import 'package:mafia_board/domain/field_validation/validation_error_code.dart';
import 'package:mafia_board/domain/field_validation/validator.dart';

class EmailFieldValidator extends FieldValidator {
  static const maxSymbols = 50;
  static const minSymbols = 6;
  final _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  FieldType get fieldType => FieldType.email;

  @override
  void validate(String? value) {
    final email = value?.trim();

    if (email == null || email.isEmpty) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.emptyField,
      );
    }
    if (!email.contains('@')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailMustContainAtSymbol,
      );
    }
    if (!email.contains('.')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailMustContainDotSymbol,
      );
    }
    if (email.startsWith('@') || email.endsWith('@')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailInvalidPositionForAtSymbol,
      );
    }
    if (email.startsWith('.') || email.endsWith('.')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailInvalidPositionForDotSymbol,
      );
    }

    if (!_emailPattern.hasMatch(email)) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidFormat,
      );
    }

    if (email.length > maxSymbols || email.length < minSymbols) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidLenght,
      );
    }
  }
}
