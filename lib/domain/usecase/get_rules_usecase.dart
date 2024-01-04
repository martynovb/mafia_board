import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetRulesUseCase extends BaseUseCase<RulesModel?, ClubModel> {

  final RulesRepo rulesRepo;

  GetRulesUseCase({required this.rulesRepo});

  @override
  Future<RulesModel?> execute({ClubModel? params}) async {
    final entity = await rulesRepo.getClubRules(params!);
    return entity != null ? RulesModel.fromEntity(entity) : null;
  }

}