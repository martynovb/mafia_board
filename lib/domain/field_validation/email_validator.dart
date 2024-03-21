import 'package:easy_localization/easy_localization.dart';
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
        errorMessage: 'validationErrorEmailIsEmpty'.tr(),
      );
    }
    if (!email.contains('@')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailMustContainAtSymbol,
        errorMessage: 'validationErrorEmailMustContainAtSymbol'.tr(),
      );
    }
    if (!email.contains('.')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailMustContainDotSymbol,
        errorMessage: 'validationErrorEmailMustContainDotSymbol'.tr(),
      );
    }
    if (email.startsWith('@') || email.endsWith('@')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailInvalidPositionForAtSymbol,
        errorMessage: 'validationErrorEmailInvalidPositionForDot'.tr(),
      );
    }
    if (email.startsWith('.') || email.endsWith('.')) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidEmailInvalidPositionForDotSymbol,
        errorMessage: 'validationErrorEmailInvalidPositionForAt'.tr(),
      );
    }

    if (!_emailPattern.hasMatch(email)) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidFormat,
        errorMessage: 'validationErrorEmailIsInvalid'.tr(),
      );
    }

    if (email.length > maxSymbols || email.length < minSymbols) {
      throw ValidationError(
        fieldType: fieldType,
        errorCode: ValidationErrorCode.invalidLenght,
        errorMessage: 'validationErrorEmailIsLength'.tr(
          args: [
            minSymbols.toString(),
            maxSymbols.toString(),
          ],
        )
      );
    }
  }
}
