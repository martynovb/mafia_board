import 'package:collection/collection.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';
import 'package:mafia_board/domain/usecase/create_club_members_usecase.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

import '../model/role.dart';

class SaveGameUseCase extends BaseUseCase<void, SaveGameResultsParams> {
  static const tag = 'SaveGameUseCase';

  final CreateClubMembersUseCase createClubMembersUseCase;
  final GameRepo gameRepo;
  final PlayersRepo playersRepo;
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;
  final GamePhaseRepo<VotePhaseModel> voteGamePhaseRepo;
  final GamePhaseRepo<NightPhaseModel> nightGamePhaseRepo;

  SaveGameUseCase({
    required this.speakGamePhaseRepo,
    required this.voteGamePhaseRepo,
    required this.nightGamePhaseRepo,
    required this.createClubMembersUseCase,
    required this.gameRepo,
    required this.playersRepo,
  });

  @override
  Future<void> execute({SaveGameResultsParams? params}) async {
    MafLogger.d(tag, '**** [START] SAVE GAME ****');
    MafLogger.d(tag, '1. [START] Create new members');
    final newMembers = await createClubMembersUseCase.execute(
      params: params!.clubModel.id,
    );
    MafLogger.d(tag, '[FINISHED] Create new members');

    MafLogger.d(tag, '2. [START] update players with created members');
    final allPlayers = playersRepo.getAllPlayers();
    allPlayers.where((player) => player.clubMember?.id == null).forEach(
      (player) {
        player.clubMember?.id = newMembers
            .firstWhereOrNull(
                (member) => member.user?.id == player.clubMember?.user.id)
            ?.id;
        playersRepo.updateAllPlayerData(player);
      },
    );
    MafLogger.d(tag, '[FINISHED] update players with created members');

    MafLogger.d(tag, '3. [START] Save current game');
    final game = await gameRepo.saveGame(
      winnerType: params.gameResults.winnerType,
      mafsLeft: allPlayers
          .where(
            (player) =>
                (player.role == Role.mafia || player.role == Role.don) &&
                player.isInGame(),
          )
          .length,
    );
    MafLogger.d(tag, '[FINISHED] Save current game (id: ${game.id})');
    if (game.id == null) {
      throw InvalidGameDataError(errorMessage: 'Game saving error');
    }
    final gameId = game.id!;
    MafLogger.d(tag, '4. [START] Save players');
    await playersRepo.savePlayers(gameId: gameId);
    MafLogger.d(tag, '[FISHED] Save players');

    MafLogger.d(tag, '5. [START] Save dayInfo list');
    final dayInfoList = await gameRepo.saveDayInfoList();
    MafLogger.d(tag, '[FINISHED] Save dayInfo list');

    MafLogger.d(tag, '6. [START] Save game phases');
    await speakGamePhaseRepo.saveGamePhases(
      gameId: gameId,
      dayInfoList: dayInfoList,
    );
    await voteGamePhaseRepo.saveGamePhases(
      gameId: gameId,
      dayInfoList: dayInfoList,
    );
    await nightGamePhaseRepo.saveGamePhases(
      gameId: gameId,
      dayInfoList: dayInfoList,
    );
    MafLogger.d(tag, '[FINISHED] Save game phases');
    MafLogger.d(tag, '**** [FINISHED] SAVE GAME ****');
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
