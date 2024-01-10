import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class UpdateRulesUseCase extends BaseUseCase<void, UpdateRulesParams> {
  final RulesRepo rulesRepo;

  UpdateRulesUseCase({required this.rulesRepo});

  @override
  Future<void> execute({UpdateRulesParams? params}) async {
    await rulesRepo.updateClubRules(
      clubModel: params!.clubModel,
      civilWin: params.civilWin,
      mafWin: params.mafWin,
      civilLoss: params.civilLoss,
      mafLoss: params.mafLoss,
      kickLoss: params.kickLoss,
      defaultBonus: params.defaultBonus,
      ppkLoss: params.ppkLoss,
      gameLoss: params.gameLoss,
      twoBestMove: params.twoBestMove,
      threeBestMove: params.threeBestMove,
    );
  }
}

class UpdateRulesParams {
  final ClubModel clubModel;

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

  UpdateRulesParams({
    required this.clubModel,
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
