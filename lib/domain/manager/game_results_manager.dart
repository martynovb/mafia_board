import 'package:collection/collection.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/role_model.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';

class GameResultsManager {
  final PlayersRepo playersRepo;
  final GetRulesUseCase getRulesUseCase;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;

  GameResultsManager({
    required this.playersRepo,
    required this.getRulesUseCase,
    required this.speakGamePhaseRepo,
  });

  Future<List<GameResultsModel>> getPlayersResults(
      {required String clubId}) async {
    WinnerType winner = _getWinner();
    RulesModel clubRules = await getRulesUseCase.execute(params: clubId);
    final allPlayers = playersRepo.getAllPlayers();
    SpeakPhaseAction? speakPhaseWithBestMove = speakGamePhaseRepo
        .getAllPhases()
        .firstWhereOrNull((speakPhase) => speakPhase.bestMove.isNotEmpty);

    for (PlayerModel player in allPlayers) {
      double score = 0;

      if (winner == WinnerType.mafia &&
          (player.role == Role.MAFIA || player.role == Role.DON)) {
        score += clubRules.mafWin;
      } else if (winner == WinnerType.mafia &&
          (player.role == Role.CIVILIAN || player.role == Role.SHERIFF)) {
        score -= clubRules.civilLoss;
        score += clubRules.defaultBonus;
      } else if (winner == WinnerType.civilian &&
          (player.role == Role.CIVILIAN || player.role == Role.SHERIFF)) {
        score += clubRules.civilWin;
      } else if (winner == WinnerType.civilian &&
          (player.role == Role.MAFIA || player.role == Role.DON)) {
        score -= clubRules.mafLoss;
        score += clubRules.defaultBonus;
      }

      if (player.isRemoved) {
        score -= clubRules.kickLoss;
      }
    }
    return [];
  }

  Future<double> _calculateBestMove(
      RulesModel rulesModel, List<int> bestMove) async {
    final mafiaPlayersSeats =
        (await playersRepo.getAllPlayersByRole([Role.MAFIA, Role.DON]))
            .map((player) => player.seatNumber);
    int count = bestMove
        .where((seatNumber) => mafiaPlayersSeats.contains(seatNumber))
        .length;

    if (count == 2) {
      return rulesModel.twoBestMove;
    } else if (count >= 3) {
      return rulesModel.threeBestMove;
    }
    return 0;
  }

  WinnerType _getWinner() {
    WinnerType winner = WinnerType.none;

    final allAvailablePlayers = playersRepo.getAllAvailablePlayers();
    int mafsCount = allAvailablePlayers
        .where((player) => player.role == Role.MAFIA || player.role == Role.DON)
        .length;

    int civilianCount = allAvailablePlayers
        .where(
          (player) =>
              player.role == Role.CIVILIAN ||
              player.role == Role.SHERIFF ||
              player.role == Role.DOCTOR ||
              player.role == Role.PUTANA ||
              player.role == Role.MANIAC,
        )
        .length;

    if (mafsCount >= civilianCount) {
      winner = WinnerType.mafia;
    } else if (mafsCount <= 0) {
      winner = WinnerType.civilian;
    }

    return winner;
  }
}
