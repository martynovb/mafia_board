import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetLastValidDayInfoUseCase extends BaseUseCase<DayInfoModel, void> {
  final GameRepo gameRepo;

  GetLastValidDayInfoUseCase({
    required this.gameRepo,
  });

  @override
  Future<DayInfoModel> execute({void params}) async {
    return DayInfoModel.fromEntity(await gameRepo.getLastValidDayInfo());
  }
}
