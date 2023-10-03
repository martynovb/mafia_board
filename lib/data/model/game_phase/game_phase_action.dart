abstract class GamePhaseAction {
  final int currentDay;
  final DateTime createdAt = DateTime.now();

  GamePhaseAction(this.currentDay);
}