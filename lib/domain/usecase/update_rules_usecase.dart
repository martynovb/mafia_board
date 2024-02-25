import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class UpdateRulesUseCase extends BaseUseCase<void, RulesModel> {
  final RulesRepo rulesRepo;

  UpdateRulesUseCase({required this.rulesRepo});

  @override
  Future<void> execute({RulesModel? params}) async {
    await rulesRepo.updateClubRules(
      rules: params!.toEntity(),
    );
  }
}
