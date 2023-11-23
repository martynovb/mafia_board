import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetRulesUseCase extends BaseUseCase<RulesModel?, String> {

  final RulesRepo rulesRepo;

  GetRulesUseCase({required this.rulesRepo});

  @override
  Future<RulesModel?> execute({String? params}) async {
    final entity = await rulesRepo.getClubRules(params!);
    return entity != null ? RulesModel.fromEntity(entity) : null;
  }

}