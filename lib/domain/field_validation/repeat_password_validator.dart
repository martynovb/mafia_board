
import 'package:easy_localization/easy_localization.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/field_validation/field_type.dart';
import 'package:mafia_board/domain/field_validation/validation_error_code.dart';
import 'package:mafia_board/domain/field_validation/validator.dart';

class RepeatPasswordFieldValidator extends FieldValidator {
  static const maxSymbols = 16;
  static const minSymbols = 6;

  @override
  FieldType get fieldType => FieldType.repeatPassword;

  @override
  void validate(String? value) {
    final repeatPassword = value?.trim();

    if (repeatPassword == null || repeatPassword.isEmpty) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidData,
        errorMessage: 'validationErrorRepeatPasswordIsEmpty'.tr(),
      );
    }
  }

  void validateRepeatPassword(String? password, String? repeatPassword) {
    if (repeatPassword != password) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidData,
        errorMessage: 'validationErrorRepeatPasswordIsNotEqual'.tr(),
      );
    }
  }
}
