import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';

abstract class GameResultsEvent {}

class CalculateResultsEvent extends GameResultsEvent {
  final ClubModel club;

  CalculateResultsEvent(this.club);
}

class SaveResultsEvent extends GameResultsEvent {
  final GameResultsModel? gameResultsModel;

  SaveResultsEvent({this.gameResultsModel});
}
