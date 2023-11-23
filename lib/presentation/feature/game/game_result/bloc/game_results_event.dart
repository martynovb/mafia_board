import 'package:mafia_board/domain/model/game_results_model.dart';

abstract class GameResultsEvent {}

class CalculateResultsEvent extends GameResultsEvent {
  final String clubId;

  CalculateResultsEvent(this.clubId);
}

class SaveResultsEvent extends GameResultsEvent {
  final GameResultsModel? gameResultsModel;

  SaveResultsEvent({this.gameResultsModel});
}
