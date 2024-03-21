class GoogleApiError {
  final int code;
  final String message;
  final String status;

  GoogleApiError({required this.code, required this.message, required this.status});

  factory GoogleApiError.fromJson(Map<String, dynamic> json) {
    var error = json['error'] ?? {};
    return GoogleApiError(
      code: error['code'] ?? 0,
      message: error['message'] ?? '',
      status: error['status'] ?? '',
    );
  }
}
