enum ValidationErrorCode {
  wrongFieldType,
  invalidData,
  invalidLenght,
  emptyField,
  invalidFormat,

  /// email
  invalidEmailMustContainAtSymbol,
  invalidEmailMustContainDotSymbol,
  invalidEmailInvalidPositionForAtSymbol,
  invalidEmailInvalidPositionForDotSymbol,
}
