class BaseState {
  final String errorMessage;
  final StateStatus status;

  BaseState({
    this.errorMessage = '',
    required this.status,
  });

  BaseState copyWith({
    String? errorMessage,
    StateStatus? status,
  }) {
    return BaseState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() => {
        'errorMessage': errorMessage,
        'status': status.name,
      };
}

enum StateStatus { inProgress, data, error, none }
