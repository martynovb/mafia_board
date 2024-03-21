import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/domain/manager/game_flow_simulator.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/model/game_model.dart';
import 'package:mafia_board/domain/manager/game_flow/game_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/vote_phase_manager.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/validator/player_validator.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class GameBloc extends HydratedBloc<GameEvent, GameState> {
  static const String _tag = 'GameBloc';
  final PlayersRepo playersRepository;
  final PlayerValidator playerValidator;
  final GameManager gameManager;
  final VotePhaseManager votePhaseManager;
  final GetCurrentGameUseCase getCurrentGameUseCase;
  final GameFlowSimulator gameFlowSimulator;

  GameBloc({
    required this.votePhaseManager,
    required this.gameManager,
    required this.playersRepository,
    required this.playerValidator,
    required this.getCurrentGameUseCase,
    required this.gameFlowSimulator,
  }) : super(InitialGameState()) {
    on<PrepareGameEvent>(_prepareGameEventHandler);
    on<StartGameEvent>(_startGameEventHandler);
    on<FinishGameEvent>(_finishGameEventHandler);
    on<NextPhaseEvent>(_nextPhaseEventHandler);
    //todo: move to speaking phase bloc
    on<PutOnVoteEvent>(_putOnVoteEventHandler);
    on<RemoveGameDataEvent>(_removeGameDataEventHandler);
    on<ResetGameDataEvent>(_resetGameDataEventHandler);
    on<SimulateFastGameCivilWinEvent>(_simulateFastGameCivilWin);
  }

  Stream<GameModel?> get gameStream => gameManager.gameStream;

  void _simulateFastGameCivilWin(
      SimulateFastGameCivilWinEvent event, emit) async {
    await gameFlowSimulator.simulateFastGame();
    final currentGame = await getCurrentGameUseCase.execute();
    emit(
      GamePhaseState(
        currentGame: currentGame,
        currentGamePhaseName: currentGame.currentDayInfo.currentPhase.name,
        club: state.club,
      ),
    );
  }

  void _resetGameDataEventHandler(ResetGameDataEvent event, emit) async {
    emit(InitialGameState());
  }

  void _removeGameDataEventHandler(RemoveGameDataEvent event, emit) async {
    await gameManager.resetGameData();
    emit(InitialGameState());
  }

  void _prepareGameEventHandler(PrepareGameEvent event, emit) async {
    emit(InitialGameState(club: event.club));
  }

  void _startGameEventHandler(StartGameEvent event, emit) async {
    try {
      playersRepository.getAllPlayers().forEach(
            (player) => playerValidator.validate(player),
          );
      await gameManager.startGame(event.clubId);
      final currentGame = await getCurrentGameUseCase.execute();
      emit(
        GameStartedState(
          currentGame: currentGame,
          currentGamePhaseName: currentGame.currentDayInfo.currentPhase.name,
          club: state.club,
        ),
      );
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(
        errorMessage: ex.errorMessage,
        club: state.club,
      ));
    }
  }

  void _finishGameEventHandler(FinishGameEvent event, emit) async {
    try {
      if (event.finishGameType == FinishGameType.ppk &&
          event.playerId != null) {
        await playersRepository.updatePlayer(event.playerId!, isPPK: true);
      }
      await gameManager.finishGame(event.finishGameType);
      if (event.finishGameType == FinishGameType.reset) {
        await gameManager.resetGameData();
        emit(CloseGameState(
          club: state.club,
        ));
      } else {
        emit(GoToGameResults(
          club: state.club,
        ));
      }
      emit(InitialGameState());
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(
        errorMessage: ex.errorMessage,
        club: state.club,
      ));
    }
  }

  Future<void> _nextPhaseEventHandler(event, emit) async {
    try {
      await gameManager.nextGamePhase();
      final currentGame = await getCurrentGameUseCase.execute();
      if (currentGame.gameStatus == GameStatus.finished) {
        emit(GoToGameResults(club: state.club));
      } else {
        emit(
          GamePhaseState(
            currentGame: currentGame,
            currentGamePhaseName: currentGame.currentDayInfo.currentPhase.name,
            club: state.club,
          ),
        );
      }
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(
        errorMessage: ex.errorMessage,
        club: state.club,
      ));
    } catch (ex) {
      MafLogger.e(_tag, 'Unexpected error: $ex');
      //emit(ErrorBoardState('Unexpected error'));
    }
  }

  void _putOnVoteEventHandler(PutOnVoteEvent event, emit) async {
    MafLogger.d(_tag, '_putOnVoteEventHandler');
    try {
      await votePhaseManager.putOnVote(event.playerOnVote.tempId);
      final currentGame = await getCurrentGameUseCase.execute();
      emit(GamePhaseState(
        currentGame: currentGame,
        currentGamePhaseName: currentGame.currentDayInfo.currentPhase.name,
        club: state.club,
      ));
    } on InvalidPlayerDataException catch (ex) {
      MafLogger.e(_tag, 'InvalidPlayerDataException');
      emit(ErrorBoardState(
        errorMessage: ex.errorMessage,
        club: state.club,
      ));
    } catch (ex) {
      MafLogger.e(_tag, 'Unexpected error: $ex');
      //emit(ErrorBoardState('Unexpected error'));
    }
  }

  void dispose() {
    gameManager.resetGameData();
    playersRepository.resetAll();
  }

  @override
  GameState? fromJson(Map<String, dynamic> json) {
    return InitialGameState(club: ClubModel.fromMap(json['club'] ?? {}));
  }

  @override
  Map<String, dynamic>? toJson(GameState state) {
    return state.toMap();
  }
}
