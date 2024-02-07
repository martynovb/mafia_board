import 'package:collection/collection.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/game_details_model.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class FetchGameDetailsUseCase extends BaseUseCase<GameDetailsModel, String> {
  final GameRepo gameRepo;
  final PlayersRepo playersRepo;
  final GamePhaseRepo gamePhaseRepo;

  FetchGameDetailsUseCase({
    required this.gameRepo,
    required this.playersRepo,
    required this.gamePhaseRepo,
  });

  @override
  Future<GameDetailsModel> execute({String? params}) async {
    final gameId = params!;
    final game = await gameRepo.fetchGame(gameId: gameId);
    final playerEntities =
        await playersRepo.fetchAllPlayersByGameId(gameId: gameId);
    final playerModels =
        playerEntities.map((entity) => PlayerModel.fromEntity(entity)).toList();
    final dayInfoList = await gameRepo.fetchAllDayInfoByGameId(
        gameId: gameId, players: playerEntities);
    final gamePhases = await gamePhaseRepo.fetchAllGamePhasesByGameId(
        gameId: gameId, players: playerModels);

    return GameDetailsModel(
      game: GameModel.fromEntity(game),
      players: playerModels.sorted((a, b) => b.total().compareTo(a.total())),
      dayInfoList:
          dayInfoList.map((entity) => DayInfoModel.fromEntity(entity)).toList(),
      gamePhases: gamePhases,
    );
  }
}
