import 'package:mafia_board/domain/model/club_model.dart';

abstract class RulesEvent {}

class LoadRulesEvent extends RulesEvent {
  final ClubModel club;

  LoadRulesEvent(this.club);
}

class CreateOrUpdateRulesEvent extends RulesEvent {
  final String? id;
  final ClubModel club;

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
    required this.club,
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
