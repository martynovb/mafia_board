import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class CreateRulesUseCase extends BaseUseCase<void, CreateRulesParams> {
  final RulesRepo rulesRepo;

  CreateRulesUseCase({required this.rulesRepo});

  @override
  Future<void> execute({CreateRulesParams? params}) async {
    await rulesRepo.createClubRules(
      clubId: params!.clubId,
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

class CreateRulesParams {
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

  CreateRulesParams({
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
