import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class UpdateDayInfoUseCase extends BaseUseCase<void, DayInfoModel> {
  final GameRepo gameRepo;

  UpdateDayInfoUseCase({
    required this.gameRepo,
  });

  @override
  Future<void> execute({DayInfoModel? params}) async {
    return await gameRepo.updateDayInfo(params?.toEntity());
  }
}
