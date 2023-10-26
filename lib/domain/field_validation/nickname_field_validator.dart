import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/field_validation/field_type.dart';
import 'package:mafia_board/domain/field_validation/validation_error_code.dart';
import 'package:mafia_board/domain/field_validation/validator.dart';

class NicknameFieldValidator extends FieldValidator {
  static const maxSymbols = 16;
  static const minSymbols = 6;

  @override
  void validate(String? value) {
    final fieldText = value?.trim();

    if (fieldText == null || fieldText.isEmpty) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidData,
        errorMessage: 'Full name should not be empty',
      );
    }
    if (fieldText.length > maxSymbols || fieldText.length < minSymbols) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.lenght,
        errorMessage:
            'Full name must be between $minSymbols and $maxSymbols characters.',
      );
    }
  }

  @override
  FieldType get fieldType => FieldType.fullName;
}
