import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class SaveGameResultsUseCase extends BaseUseCase<void, SaveGameResultsParams> {
  final GameRepo gameRepo;

  SaveGameResultsUseCase({required this.gameRepo});

  @override
  Future<void> execute({SaveGameResultsParams? params}) async {
    await gameRepo.saveGameResults(
      clubModel: params!.clubModel,
      gameResultsModel: params.gameResults,
    );
  }
}

class SaveGameResultsParams {
  final GameResultsModel gameResults;
  final ClubModel clubModel;

  SaveGameResultsParams({
    required this.gameResults,
    required this.clubModel,
  });
}
