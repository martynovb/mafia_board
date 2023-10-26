

import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/field_validation/field_type.dart';
import 'package:mafia_board/domain/field_validation/validation_error_code.dart';
import 'package:mafia_board/domain/field_validation/validator.dart';

class PasswordFieldValidator extends FieldValidator {
  static const maxSymbols = 16;
  static const minSymbols = 6;
  final _pattern = RegExp(r'^(?=.*[A-Z])(?=.*\d).+$');

  @override
  FieldType get fieldType => FieldType.password;

  @override
  void validate(String? value) {
    final password = value?.trim();

    if (password == null || password.isEmpty) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidData,
        errorMessage: 'Password should not be empty',
      );
    }

    if (_pattern.hasMatch(password)) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidData,
        errorMessage:
            'Password should contain at least one uppercase letter and one digit',
      );
    }

    if (password.length > maxSymbols || password.length < minSymbols) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.lenght,
        errorMessage:
            'Password must be between $minSymbols and $maxSymbols characters.',
      );
    }
  }
}
