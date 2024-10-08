import 'package:easy_localization/easy_localization.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/field_validation/field_type.dart';
import 'package:mafia_board/domain/field_validation/validation_error_code.dart';
import 'package:mafia_board/domain/field_validation/validator.dart';

class NicknameFieldValidator extends FieldValidator {
  static const maxSymbols = 24;
  static const minSymbols = 2;

  @override
  void validate(String? value) {
    final fieldText = value?.trim();

    if (fieldText == null || fieldText.isEmpty) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidData,
        errorMessage: 'validationErrorNicknameIsEmpty'.tr(),
      );
    }
    if (fieldText.length > maxSymbols || fieldText.length < minSymbols) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidLenght,
        errorMessage: 'validationErrorNicknameIsLength'.tr(
          args: [
            minSymbols.toString(),
            maxSymbols.toString(),
          ],
        ),
      );
    }
  }

  @override
  FieldType get fieldType => FieldType.fullName;
}
