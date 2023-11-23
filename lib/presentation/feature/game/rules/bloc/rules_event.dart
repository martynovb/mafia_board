abstract class RulesEvent {}

class LoadRulesEvent extends RulesEvent {
  final String clubId;

  LoadRulesEvent(this.clubId);
}

class CreateOrUpdateRulesEvent extends RulesEvent {
  final String? id;
  final String clubId;

  final double civilWin;
  final double mafWin;
  final double civilLoss;
  final double mafLoss;
  final double kickLoss;
  final double defaultBonus;
  final double ppkLoss;
  final double gameLoss;
  final double twoBestMove;
  final double threeBestMove;

  CreateOrUpdateRulesEvent({
    this.id,
    required this.clubId,
    required this.civilWin,
    required this.mafWin,
    required this.civilLoss,
    required this.mafLoss,
    required this.kickLoss,
    required this.defaultBonus,
    required this.ppkLoss,
    required this.gameLoss,
    required this.twoBestMove,
    required this.threeBestMove,
  });
}
