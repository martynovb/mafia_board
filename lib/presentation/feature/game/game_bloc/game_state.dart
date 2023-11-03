import 'package:mafia_board/data/model/game_info_model.dart';

abstract class GameState {}

class InitialBoardState extends GameState {}

class ErrorBoardState extends GameState {
  final String errorMessage;

  ErrorBoardState(this.errorMessage);
}

class GamePhaseState extends GameState {
  String currentGamePhaseName = '';
  GameInfoModel? gameInfo;

  GamePhaseState(this.gameInfo, this.currentGamePhaseName);
}
