import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class CreateRulesUseCase extends BaseUseCase<void, RulesModel> {
  final RulesRepo rulesRepo;

  CreateRulesUseCase({required this.rulesRepo});

  @override
  Future<void> execute({RulesModel? params}) async {
    await rulesRepo.createClubRules(
      rules: params!.toEntity()
    );
  }
}
