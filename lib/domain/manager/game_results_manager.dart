import 'package:collection/collection.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/player_score_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/save_game_results_usecase.dart';

class GameResultsManager {
  final PlayersRepo playersRepo;
  final GetRulesUseCase getRulesUseCase;
  final SaveGameResultsUseCase saveGameResultsUseCase;
  final GamePhaseRepo<SpeakPhaseAction> speakGamePhaseRepo;
  final GamePhaseRepo<NightPhaseAction> nightGamePhaseRepo;

  GameResultsManager({
    required this.playersRepo,
    required this.getRulesUseCase,
    required this.saveGameResultsUseCase,
    required this.speakGamePhaseRepo,
    required this.nightGamePhaseRepo,
  });

  Future<GameResultsModel> getPlayersResults({required ClubModel club}) async {
    WinnerType winnerIfPPK = _getWinnerIfPPK();
    WinnerType winner =
        winnerIfPPK == WinnerType.none ? _getWinner() : winnerIfPPK;

    RulesModel clubRules =
        (await getRulesUseCase.execute(params: club)) ?? RulesModel.empty();
    final allPlayers = playersRepo.getAllPlayers();
    SpeakPhaseAction? speakPhaseWithBestMove = speakGamePhaseRepo
        .getAllPhases()
        .firstWhereOrNull((speakPhase) => speakPhase.bestMove.isNotEmpty);
    final firstKilledPlayer = _findFirstKilledPlayer();

    final List<PlayerScoreModel> scoreList = [];

    for (PlayerModel player in allPlayers) {
      final playerScore = PlayerScoreModel(player: player);
      if (player.isPPK) {
        playerScore.isPPK = true;
        playerScore.gamePoints -= clubRules.ppkLoss;
      } else if (winner == WinnerType.mafia &&
          (player.role == Role.MAFIA || player.role == Role.DON)) {
        playerScore.gamePoints += clubRules.mafWin;
      } else if (winner == WinnerType.mafia &&
          (player.role == Role.CIVILIAN || player.role == Role.SHERIFF)) {
        playerScore.gamePoints -= clubRules.civilLoss;
        playerScore.gamePoints += clubRules.defaultBonus;
      } else if (winner == WinnerType.civilian &&
          (player.role == Role.CIVILIAN || player.role == Role.SHERIFF)) {
        playerScore.gamePoints += clubRules.civilWin;
      } else if (winner == WinnerType.civilian &&
          (player.role == Role.MAFIA || player.role == Role.DON)) {
        playerScore.gamePoints -= clubRules.mafLoss;
        playerScore.gamePoints += clubRules.defaultBonus;
      }

      if (!player.isPPK) {
        if (player.isDisqualified) {
          playerScore.gamePoints -= clubRules.kickLoss;
        } else if (speakPhaseWithBestMove != null &&
            player.id == speakPhaseWithBestMove.playerId &&
            !mafiaRoles().contains(player.role)) {
          playerScore.bestMove += await _calculateBestMove(
            clubRules,
            speakPhaseWithBestMove.bestMove,
          );
        }
      }

      if (player.id == firstKilledPlayer?.id) {
        playerScore.isFirstKilled = true;
      }

      scoreList.add(playerScore);
    }

    return GameResultsModel(
      club: club,
      winnerType: winner,
      scoreList: scoreList.sorted((a, b) => b.total().compareTo(a.total())),
    );
  }

  Future<void> saveResults({
    required ClubModel clubModel,
    required GameResultsModel gameResultsModel,
  }) async =>
      saveGameResultsUseCase.execute(
        params: SaveGameResultsParams(
          gameResults: gameResultsModel,
          clubModel: clubModel,
        ),
      );

  Future<double> _calculateBestMove(
    RulesModel rulesModel,
    List<int> bestMove,
  ) async {
    if (bestMove.isEmpty) {
      return 0;
    }
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

  WinnerType _getWinnerIfPPK() {
    final allPlayers = playersRepo.getAllPlayers();
    Role ppkRole =
        allPlayers.firstWhereOrNull((player) => player.isPPK)?.role ??
            Role.NONE;
    if (ppkRole == Role.NONE) {
      return WinnerType.none;
    }

    if (civilianRoles().contains(ppkRole)) {
      return WinnerType.mafia;
    } else if (mafiaRoles().contains(ppkRole)) {
      return WinnerType.mafia;
    }

    return WinnerType.none;
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

  PlayerModel? _findFirstKilledPlayer() {
    return nightGamePhaseRepo
        .getAllPhases()
        .sorted((a, b) =>
            a.createdAt.millisecond.compareTo(b.createdAt.millisecond))
        .firstWhereOrNull((nightPhase) => nightPhase.killedPlayer != null)
        ?.killedPlayer;
  }

  double _calculateCompensation() {
    return 0;
  }
}
