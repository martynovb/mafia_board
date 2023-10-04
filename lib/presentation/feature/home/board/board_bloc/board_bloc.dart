import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/domain/exceptions/invalid_player_data_exception.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  static const String _tag = 'BoardBloc';
  final BoardRepository boardRepository;
  final PlayerValidator playerValidator;
  final GamePhaseManager gamePhaseManager;
  StreamSubscription? _gamePhaseSubscription;

  BoardBloc({
    required this.gamePhaseManager,
    required this.boardRepository,
    required this.playerValidator,
  }) : super(InitialBoardState()) {
    on<StartGameEvent>(_startGameEventHandler);
    on<FinishGameEvent>(_finishGameEventHandler);
    on<NextPhaseEvent>(_nextPhaseEventHandler);
    on<PutOnVoteEvent>(_putOnVoteEventHandler);
  }

  void _subscribeToGamePhase() {
    _gamePhaseSubscription = gamePhaseManager.gamePhaseStream.listen((phase) {
      // todo: change emit
      emit(GamePhaseState(phase, mapGamePhaseName(phase)));
    });
  }

  void _unsubscribeFromGamePhase() {
    _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
  }

  void _startGameEventHandler(event, emit) async {
    try {
      boardRepository.getAllPlayers().forEach(
            (player) => playerValidator.validate(player),
          );
      _subscribeToGamePhase();
      gamePhaseManager.startGame();
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }

  void _finishGameEventHandler(event, emit) async {
    try {
      gamePhaseManager.finishGame();
      _unsubscribeFromGamePhase();
      emit(InitialBoardState());
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }

  void _nextPhaseEventHandler(event, emit) async {
    try {
      gamePhaseManager.nextGamePhase();
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }

  void _putOnVoteEventHandler(PutOnVoteEvent event, emit) async {
    MafLogger.d(_tag, '_putOnVoteEventHandler');
    try {
      final phase = await gamePhaseManager.gamePhase;
      MafLogger.d(_tag, '$phase');
      if (!phase.isSpeakPhaseFinished()) {
        final currentSpeaker = phase.getCurrentSpeakPhase()?.player;
        if (currentSpeaker != null) {
          MafLogger.d(_tag, 'Current speaker: ${currentSpeaker.nickname}');
          MafLogger.d(_tag, 'Put on vote: ${event.playerOnVote.nickname}');
          if (gamePhaseManager.putOnVote(
            currentPlayer: currentSpeaker,
            playerToVote: event.playerOnVote,
          )) {
            emit(GamePhaseState(
                await gamePhaseManager.gamePhase, mapGamePhaseName(phase)));
          }
          return;
        } else {
          emit(ErrorBoardState("Can't put on vote: Not found current speaker"));
        }
      } else {
        emit(ErrorBoardState("Can't put on vote: it's not speaking phase"));
      }
    } on InvalidPlayerDataException catch (ex) {
      MafLogger.e(_tag, 'InvalidPlayerDataException');
      emit(ErrorBoardState(ex.errorMessage));
    } catch (ex) {
      MafLogger.e(_tag, 'Unexpected error');
      emit(ErrorBoardState('Unexpected error'));
    }
  }

  String mapGamePhaseName(GamePhaseModel phase) {
    if (!phase.isSpeakPhaseFinished()) {
      return 'Speaking';
    } else if (!phase.isVotingPhaseFinished()) {
      return 'Voting';
    } else if (!phase.isNightPhaseFinished()) {
      return 'Night';
    } else {
      return 'Unknown';
    }
  }

  void dispose() {
    _gamePhaseSubscription?.cancel();
    _gamePhaseSubscription = null;
  }
}
