import 'package:mafia_board/domain/model/game_results_model.dart';

abstract class GameResultsState {}

class InitialGameResultsState extends GameResultsState {}

class ShowGameResultsState extends GameResultsState {
  final GameResultsModel gameResultsModel;

  ShowGameResultsState(this.gameResultsModel);
}

class GameResultsUploaded extends GameResultsState {

}
