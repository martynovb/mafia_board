import 'package:mafia_board/domain/field_validation/field_type.dart';

abstract class FieldValidator {
  void validate(String? value);
  FieldType get fieldType;
}