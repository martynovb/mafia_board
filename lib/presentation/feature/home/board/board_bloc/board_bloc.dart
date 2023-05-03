import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/domain/exceptions/invalid_player_data_exception.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final BoardRepository boardRepository;
  final PlayerValidator playerValidator;

  BoardBloc({
    required this.boardRepository,
    required this.playerValidator,
  }) : super(InitialBoardState()) {
    on<StartGameEvent>(_startGameEventHandler);
  }

  void _startGameEventHandler(event, emit) async {
    try {
      boardRepository.getAllPlayers().forEach(
            (player) => playerValidator.validate(player),
          );
      emit(StartGameState());
    } on InvalidPlayerDataException catch (ex) {
      emit(ErrorBoardState(ex.errorMessage));
    }
  }
}
