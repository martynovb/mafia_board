import 'package:mafia_board/data/entity/rules_entity.dart';

class RulesModel {
  final String id;

  final double civilWin;
  final double mafWin;
  final double civilLoss;
  final double mafLoss;
  final double kickLoss;
  final double defaultBonus;
  final double ppkLoss;
  final double defaultGameLoss;
  final double twoBestMove;
  final double threeBestMove;

  RulesModel({
    required this.id,
    required this.civilWin,
    required this.mafWin,
    required this.civilLoss,
    required this.mafLoss,
    required this.kickLoss,
    required this.defaultBonus,
    required this.ppkLoss,
    required this.defaultGameLoss,
    required this.twoBestMove,
    required this.threeBestMove,
  });

  RulesModel.empty()
      : id = '',
        civilWin = 0.0,
        mafWin = 0.0,
        civilLoss = 0.0,
        mafLoss = 0.0,
        kickLoss = 0.0,
        defaultBonus = 0.0,
        ppkLoss = 0.0,
        defaultGameLoss = 0.0,
        twoBestMove = 0.0,
        threeBestMove = 0.0;

  RulesModel.fromEntity(RulesEntity entity)
      : id = entity.id ?? '',
        civilWin = entity.civilWin ?? 0.0,
        mafWin = entity.mafWin ?? 0.0,
        civilLoss = entity.civilLoss ?? 0.0,
        mafLoss = entity.mafLoss ?? 0.0,
        kickLoss = entity.kickLoss ?? 0.0,
        defaultBonus = entity.defaultBonus ?? 0.0,
        ppkLoss = entity.ppkLoss ?? 0.0,
        defaultGameLoss = entity.defaultGameLoss ?? 0.0,
        twoBestMove = entity.twoBestMove ?? 0.0,
        threeBestMove = entity.threeBestMove ?? 0.0;

  RulesEntity toEntity() => RulesEntity(
        id: id,
        civilWin: civilWin,
        mafWin: mafWin,
        civilLoss: civilLoss,
        mafLoss: mafLoss,
        kickLoss: kickLoss,
        defaultBonus: defaultBonus,
        ppkLoss: ppkLoss,
        defaultGameLoss: defaultGameLoss,
        twoBestMove: twoBestMove,
        threeBestMove: threeBestMove,
      );
}
