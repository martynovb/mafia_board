abstract class GameResultsEvent {}

class CalculateResultsEvent extends GameResultsEvent {
  final String clubId;

  CalculateResultsEvent(this.clubId);
}

class SaveResultsEvent extends GameResultsEvent {}
