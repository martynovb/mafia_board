import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class SaveGameResultsUseCase extends BaseUseCase<void, GameResultsModel> {
  final GameRepo gameRepo;

  SaveGameResultsUseCase({required this.gameRepo});

  @override
  Future<void> execute({GameResultsModel? params}) async {
    await gameRepo.saveGameResults(gameResultsModel: params!);
  }
}
