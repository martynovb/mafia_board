import 'package:mafia_board/data/entity/rules_entity.dart';
import 'package:mafia_board/domain/model/club_model.dart';

abstract class RulesRepo {
  Future<RulesEntity?> getClubRules(ClubModel club);

  Future<void> updateClubRules({
    required ClubModel clubModel,
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
    required ClubModel clubModel,
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
