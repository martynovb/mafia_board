import 'package:collection/collection.dart';
import 'package:mafia_board/data/constants/firestore_keys.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/model/rules_model.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/save_game_usecase.dart';

class GameResultsManager {
  final PlayersRepo playersRepo;
  final GetRulesUseCase getRulesUseCase;
  final SaveGameUseCase saveGameResultsUseCase;
  final GamePhaseRepo<SpeakPhaseModel> speakGamePhaseRepo;
  final GamePhaseRepo<NightPhaseModel> nightGamePhaseRepo;

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

    RulesModel clubRules = await getRulesUseCase.execute(params: club.id);
    var allPlayers = playersRepo.getAllPlayers();
    SpeakPhaseModel? speakPhaseWithBestMove = speakGamePhaseRepo
        .getAllPhases()
        .firstWhereOrNull((speakPhase) => speakPhase.bestMove.isNotEmpty);
    final firstKilledPlayer = _findFirstKilledPlayer();

    for (PlayerModel player in allPlayers) {
      final isPlayerTeamWon = (winner == WinnerType.mafia &&
              (player.role == Role.mafia || player.role == Role.don)) ||
          (winner == WinnerType.civilian &&
              (player.role == Role.civilian || player.role == Role.sheriff));

      if (player.isPPK) {
        player.isPPK = true;
        player.gamePoints += clubRules.getSetting(FirestoreKeys.ppkLoss);
      } else if (winner == WinnerType.mafia &&
          (player.role == Role.mafia || player.role == Role.don)) {
        player.gamePoints += clubRules.getSetting(FirestoreKeys.mafWin);
      } else if (winner == WinnerType.mafia &&
          (player.role == Role.civilian || player.role == Role.sheriff)) {
        player.gamePoints += clubRules.getSetting(FirestoreKeys.civilLoss);
        player.gamePoints += clubRules.getSetting(FirestoreKeys.defaultBonus);
      } else if (winner == WinnerType.civilian &&
          (player.role == Role.civilian || player.role == Role.sheriff)) {
        player.gamePoints += clubRules.getSetting(FirestoreKeys.civilWin);
      } else if (winner == WinnerType.civilian &&
          (player.role == Role.mafia || player.role == Role.don)) {
        player.gamePoints += clubRules.getSetting(FirestoreKeys.mafLoss);
        player.gamePoints += clubRules.getSetting(FirestoreKeys.defaultBonus);
      }

      if (!player.isPPK) {
        if (player.isDisqualified) {
          player.gamePoints +=
              clubRules.getSetting(FirestoreKeys.disqualificationLoss);
        } else if (speakPhaseWithBestMove != null &&
            player.tempId == speakPhaseWithBestMove.playerTempId &&
            !mafiaRoles().contains(player.role)) {
          player.bestMove += await _calculateBestMove(
            player,
            clubRules,
            speakPhaseWithBestMove.bestMove,
            isPlayerTeamWon,
          );
        }
      }

      if (player.tempId == firstKilledPlayer?.tempId) {
        player.isFirstKilled = true;
      }

      await playersRepo.updateAllPlayerData(player);
    }

    allPlayers = playersRepo.getAllPlayers();
    return GameResultsModel(
      club: club,
      winnerType: winner,
      allPlayers: allPlayers.sorted((a, b) => b.total().compareTo(a.total())),
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
    PlayerModel player,
    RulesModel rules,
    List<PlayerModel> bestMove,
    bool isPlayerTeamWon,
  ) async {
    if (player.role == Role.mafia ||
        player.role == Role.don ||
        bestMove.isEmpty) {
      return 0;
    }
    final mafiaPlayersTempIds =
        (await playersRepo.getAllPlayersByRole([Role.mafia, Role.don])).map(
      (player) => player.tempId,
    );
    int count = bestMove
        .where(
          (player) =>
              mafiaPlayersTempIds.any((tempId) => tempId == player.tempId),
        )
        .length;

    if (count == 0) {
      return rules.settings[isPlayerTeamWon
              ? FirestoreKeys.bestMoveWin0
              : FirestoreKeys.bestMoveLoss0] ??
          0.0;
    } else if (count == 1) {
      return rules.settings[isPlayerTeamWon
              ? FirestoreKeys.bestMoveWin1
              : FirestoreKeys.bestMoveLoss1] ??
          0.0;
    } else if (count == 2) {
      return rules.settings[isPlayerTeamWon
              ? FirestoreKeys.bestMoveWin1
              : FirestoreKeys.bestMoveLoss1] ??
          0.0;
    } else if (count == 3) {
      return rules.settings[isPlayerTeamWon
              ? FirestoreKeys.bestMoveWin1
              : FirestoreKeys.bestMoveLoss1] ??
          0.0;
    }
    return 0;
  }

  WinnerType _getWinnerIfPPK() {
    final allPlayers = playersRepo.getAllPlayers();
    Role ppkRole =
        allPlayers.firstWhereOrNull((player) => player.isPPK)?.role ??
            Role.none;
    if (ppkRole == Role.none) {
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
        .where((player) => player.role == Role.mafia || player.role == Role.don)
        .length;

    int civilianCount = allAvailablePlayers
        .where(
          (player) =>
              player.role == Role.civilian ||
              player.role == Role.sheriff ||
              player.role == Role.doctor ||
              player.role == Role.putana ||
              player.role == Role.maniac,
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
            a.updatedAt.millisecond.compareTo(b.updatedAt.millisecond))
        .firstWhereOrNull((nightPhase) => nightPhase.killedPlayer != null)
        ?.killedPlayer;
  }
}
