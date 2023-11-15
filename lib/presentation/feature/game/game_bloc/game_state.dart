import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';

abstract class GameState {}

class InitialBoardState extends GameState {}

class GoToGameResults extends GameState {}

class ErrorBoardState extends GameState {
  final String errorMessage;

  ErrorBoardState(this.errorMessage);
}

class GamePhaseState extends GameState {
  String currentGamePhaseName = '';
  GameModel? currentGame;

  GamePhaseState(this.currentGame, this.currentGamePhaseName);
}
