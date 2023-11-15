import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetLastDayInfoUseCase extends BaseUseCase<DayInfoModel, void> {
  final GameRepo gameRepo;

  GetLastDayInfoUseCase({
    required this.gameRepo,
  });

  @override
  Future<DayInfoModel> execute({void params}) async {
    return DayInfoModel.fromEntity(await gameRepo.getLastDayInfo());
  }
}
