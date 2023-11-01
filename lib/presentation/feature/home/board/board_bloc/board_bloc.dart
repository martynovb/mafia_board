import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/model/game_info_model.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  static const String _tag = 'BoardBloc';
  final BoardRepo boardRepository;
  final PlayerValidator playerValidator;
  final GameManager gameManager;
  final VotePhaseManager votePhaseManager;

  BoardBloc({
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

  Stream<GameInfoModel> get gameInfoStream => gameManager.gameInfoStream;

  void _startGameEventHandler(event, emit) async {
    try {
      boardRepository.getAllPlayers().forEach(
            (player) => playerValidator.validate(player),
          );
      final gameInfo = await gameManager.startGame();
      emit(GamePhaseState(gameInfo, gameInfo.currentPhase.name));
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }

  void _finishGameEventHandler(event, emit) async {
    try {
      gameManager.finishGame();
      emit(InitialBoardState());
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }

  Future<void> _nextPhaseEventHandler(event, emit) async {
    try {
      final gameInfo = await gameManager.nextGamePhase();
      emit(GamePhaseState(gameInfo, gameInfo?.currentPhase.name ?? ''));
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
      final gameInfo = await gameManager.gameInfo;
      emit(GamePhaseState(await gameManager.gameInfo,
          gameInfo?.currentPhase.name ?? 'Unknown'));
    } on InvalidPlayerDataException catch (ex) {
      MafLogger.e(_tag, 'InvalidPlayerDataException');
      emit(ErrorBoardState(ex.errorMessage));
    } catch (ex) {
      MafLogger.e(_tag, 'Unexpected error: $ex');
      //emit(ErrorBoardState('Unexpected error'));
    }
  }

  void dispose() {
  }
}
