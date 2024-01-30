import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/history/history_repository.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/domain/usecase/base_usecase.dart';

class RemoveGameDataUseCase extends BaseUseCase<void, void> {
  final GameRepo gameRepo;
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;
  final GamePhaseRepo<VotePhaseModel> voteGamePhaseRepo;
  final GamePhaseRepo<NightPhaseModel> nightGamePhaseRepo;
  final PlayersRepo playersRepo;
  final HistoryRepo historyRepo;

  RemoveGameDataUseCase({
    required this.gameRepo,
    required this.speakGamePhaseRepo,
    required this.voteGamePhaseRepo,
    required this.nightGamePhaseRepo,
    required this.playersRepo,
    required this.historyRepo,
  });

  @override
  Future<void> execute({void params}) async {
    await gameRepo.removeGameData();
    speakGamePhaseRepo.deleteAll();
    voteGamePhaseRepo.deleteAll();
    nightGamePhaseRepo.deleteAll();
    playersRepo.resetAll();
    historyRepo.deleteAll();
  }
}
