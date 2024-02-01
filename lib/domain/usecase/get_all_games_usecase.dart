import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class GetAllGamesUsecase extends BaseUseCase<List<GameModel>, String> {
  final GameRepo gameRepo;

  GetAllGamesUsecase({
    required this.gameRepo,
  });

  @override
  Future<List<GameModel>> execute({String? params}) async {
    final games = await gameRepo.fetchAllGamesByClubId(clubId: params!);
    return games.map((entity) => GameModel.fromEntity(entity)).toList();
  }
}
