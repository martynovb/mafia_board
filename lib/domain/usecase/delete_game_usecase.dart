import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class DeleteGameUseCase extends BaseUseCase<void, String> {
  final GameRepo gameRepo;
  final PlayersRepo playersRepo;
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;
  final GamePhaseRepo<VotePhaseModel> voteGamePhaseRepo;
  final GamePhaseRepo<NightPhaseModel> nightGamePhaseRepo;

  DeleteGameUseCase({
    required this.gameRepo,
    required this.playersRepo,
    required this.speakGamePhaseRepo,
    required this.voteGamePhaseRepo,
    required this.nightGamePhaseRepo,
  });

  @override
  Future<void> execute({String? params}) async {
    final gameId = params!;
    await gameRepo.removeGame(gameId: gameId);
    await gameRepo.removeAllDayInfoByGameId(gameId: gameId);
    await playersRepo.deleteAllPlayersByGameId(gameId: gameId);
    await speakGamePhaseRepo.deleteAllGamePhasesByGameId(
      phaseType: PhaseType.speak,
      gameId: gameId,
    );
    await voteGamePhaseRepo.deleteAllGamePhasesByGameId(
      phaseType: PhaseType.vote,
      gameId: gameId,
    );
    await nightGamePhaseRepo.deleteAllGamePhasesByGameId(
      phaseType: PhaseType.night,
      gameId: gameId,
    );
  }
}
