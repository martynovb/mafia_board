import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class CreateGameUseCase extends BaseUseCase<GameModel, CreateGameParams> {
  final GameRepo gameRepo;

  CreateGameUseCase({required this.gameRepo});

  @override
  Future<GameModel> execute({CreateGameParams? params}) async {
    return GameModel.fromEntity(
      await gameRepo.createGame(
        clubId: params!.clubId,
        gameStatus: params.gameStatus,
      ),
      null,
    );
  }
}

class CreateGameParams {
  final String clubId;
  final GameStatus gameStatus;

  CreateGameParams({
    required this.clubId,
    required this.gameStatus,
  });
}
