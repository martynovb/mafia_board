import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/domain/exceptions/invalid_player_data_exception.dart';
import 'package:mafia_board/domain/game_phase_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
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
    on<NextPhaseEvent>(_nextPhaseEventHandler);
    on<PutOnVoteEvent>(_putOnVoteEventHandler);
  }

  void _listenToGamePhase() {
    _gamePhaseSubscription = gamePhaseManager.gamePhaseStream.listen((phase) {
      // todo: change emit
      emit(GamePhaseState(phase, mapGamePhaseName(phase)));
    });
  }

  void _startGameEventHandler(event, emit) async {
    try {
      boardRepository.getAllPlayers().forEach(
            (player) => playerValidator.validate(player),
          );
      _listenToGamePhase();
      gamePhaseManager.startGame();
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
    try {
      gamePhaseManager.putOnVote(event.whoPutOnVote, event.playerOnVote);
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
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
