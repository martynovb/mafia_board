import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetCurrentGameUseCase extends BaseUseCase<GameModel, void> {
  final GameRepo gameRepo;

  GetCurrentGameUseCase({
    required this.gameRepo,
  });

  @override
  Future<GameModel> execute({void params}) async {
    return GameModel.fromEntity(
      await gameRepo.getLastActiveGame(),
      await gameRepo.getLastValidDayInfo(),
    );
  }
}
