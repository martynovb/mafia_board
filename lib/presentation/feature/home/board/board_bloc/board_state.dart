abstract class BoardState {}

class InitialBoardState extends BoardState {}

class ErrorBoardState extends BoardState {
  final String errorMessage;

  ErrorBoardState(this.errorMessage);
}

class StartGameState extends BoardState {}
