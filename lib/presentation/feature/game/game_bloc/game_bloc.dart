import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const String _tag = 'BoardBloc';
  final PlayersRepo boardRepository;
  final PlayerValidator playerValidator;
  final GameManager gameManager;
  final VotePhaseManager votePhaseManager;

  GameBloc({
    required this.votePhaseManager,
    required this.gameManager,
    required this.boardRepository,
    required this.playerValidator,
  }) : super(InitialBoardState()) {
    on<StartGameEvent>(_startGameEventHandler);
    on<FinishGameEvent>(_finishGameEventHandler);
    on<NextPhaseEvent>(_nextPhaseEventHandler);
    on<PutOnVoteEvent>(_putOnVoteEventHandler);
  }

  Stream<DayInfoModel> get dayInfoStream => gameManager.dayInfoStream;

  void _startGameEventHandler(event, emit) async {
    try {
      boardRepository.getAllPlayers().forEach(
            (player) => playerValidator.validate(player),
          );
      final dayInfo = await gameManager.startGame();
      emit(GamePhaseState(dayInfo, dayInfo.currentPhase.name));
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }

  void _finishGameEventHandler(FinishGameEvent event, emit) async {
    try {
      await gameManager.finishGame(event.finishGameType);
      if (event.finishGameType != FinishGameType.remove) {
        emit(GoToGameResults());
      }
      emit(InitialBoardState());
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }

  Future<void> _nextPhaseEventHandler(event, emit) async {
    try {
      final dayInfo = await gameManager.nextGamePhase();
      emit(GamePhaseState(dayInfo, dayInfo?.currentPhase.name ?? ''));
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    } catch (ex) {
      MafLogger.e(_tag, 'Unexpected error: $ex');
      //emit(ErrorBoardState('Unexpected error'));
    }
  }

  void _putOnVoteEventHandler(PutOnVoteEvent event, emit) async {
    MafLogger.d(_tag, '_putOnVoteEventHandler');
    try {
      votePhaseManager.putOnVote(event.playerOnVote.id);
      final dayInfo = await gameManager.dayInfo;
      emit(GamePhaseState(await gameManager.dayInfo,
          dayInfo?.currentPhase.name ?? 'Unknown'));
    } on InvalidPlayerDataException catch (ex) {
      MafLogger.e(_tag, 'InvalidPlayerDataException');
      emit(ErrorBoardState(ex.errorMessage));
    } catch (ex) {
      MafLogger.e(_tag, 'Unexpected error: $ex');
      //emit(ErrorBoardState('Unexpected error'));
    }
  }

  void dispose() {}
}
