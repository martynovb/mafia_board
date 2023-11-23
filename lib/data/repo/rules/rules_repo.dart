import 'package:mafia_board/data/entity/rules_entity.dart';

abstract class RulesRepo {
  Future<RulesEntity?> getClubRules(String clubId);

  Future<void> updateClubRules({
    required String id,
    required double civilWin,
    required double mafWin,
    required double civilLoss,
    required double mafLoss,
    required double kickLoss,
    required double defaultBonus,
    required double ppkLoss,
    required double gameLoss,
    required double twoBestMove,
    required double threeBestMove,
  });

  Future<void> createClubRules({
    required String clubId,
    required double civilWin,
    required double mafWin,
    required double civilLoss,
    required double mafLoss,
    required double kickLoss,
    required double defaultBonus,
    required double ppkLoss,
    required double gameLoss,
    required double twoBestMove,
    required double threeBestMove,
  });
}
