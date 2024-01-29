import 'package:collection/collection.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';
import 'package:mafia_board/domain/usecase/create_club_members_usecase.dart';

class SaveGameUseCase extends BaseUseCase<void, SaveGameResultsParams> {
  final CreateClubMembersUseCase createClubMembersUseCase;
  final GameRepo gameRepo;
  final PlayersRepo playersRepo;

  SaveGameUseCase({
    required this.createClubMembersUseCase,
    required this.gameRepo,
    required this.playersRepo,
  });

  @override
  Future<void> execute({SaveGameResultsParams? params}) async {
    // 1. add new members if it is not
    final newMembers = await createClubMembersUseCase.execute(
      params: params!.clubModel.id,
    );

    // 2. update players with created members
    playersRepo
        .getAllPlayers()
        .where((player) => player.clubMember?.id == null)
        .forEach(
      (player) {
        player.clubMember?.id = newMembers
            .firstWhereOrNull(
                (member) => member.user?.id == player.clubMember?.user.id)
            ?.id;
        playersRepo.updateAllPlayerData(player);
      },
    );

    // 3. save game to get game id
    final game = await gameRepo.saveGame();
    if(game.id != null) {
      await playersRepo.savePlayers(gameId: game.id!);
    } else {
      throw InvalidDataError('Game saving error');
    }

    // 4. save day info with created gameId

    // 5. save game phases with dayInfoId

    // 6. recalculate win rate for club

    // 7. recalculate win rate for each clubMember
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
