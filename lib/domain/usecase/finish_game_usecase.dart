import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class FinishGameUseCase extends BaseUseCase<GameModel, void> {
  final GameRepo gameRepo;

  FinishGameUseCase({required this.gameRepo});

  @override
  Future<GameModel> execute({void params}) async {
    return GameModel.fromEntity(
      await gameRepo.finishCurrentGame(),
      await gameRepo.getLastValidDayInfo(),
    );
  }
}
