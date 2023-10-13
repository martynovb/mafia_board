import 'package:mafia_board/data/model/game_info_model.dart';

abstract class BoardState {}

class InitialBoardState extends BoardState {}

class ErrorBoardState extends BoardState {
  final String errorMessage;

  ErrorBoardState(this.errorMessage);
}

class GamePhaseState extends BoardState {
  String currentGamePhaseName = '';
  GameInfoModel? gameInfo;

  GamePhaseState(this.gameInfo, this.currentGamePhaseName);
}
