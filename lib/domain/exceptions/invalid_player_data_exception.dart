class InvalidPlayerDataException implements Exception {
  final String errorMessage;

  InvalidPlayerDataException(this.errorMessage);
}
