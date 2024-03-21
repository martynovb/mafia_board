import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetRulesUseCase extends BaseUseCase<RulesModel, String> {
  final RulesRepo rulesRepo;

  GetRulesUseCase({required this.rulesRepo});

  @override
  Future<RulesModel> execute({String? params}) async {
    final entity = await rulesRepo.getClubRules(clubId: params!);
    if (entity == null) {
      final model = RulesModel(
          id: null,
          clubId: params,
          settings: RulesModel.fillSettingsIfAbsent({}));

      return model;
    }
    final model = RulesModel.fromEntity(entity);
    model.settings = RulesModel.fillSettingsIfAbsent(model.settings);
    return model;
  }
}
