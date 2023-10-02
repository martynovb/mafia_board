import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/domain/game_phase_manager.dart';

class GameHistoryBloc extends Bloc<LoadGameHistoryEvent, GameHistoryState> {
  static const String _tag = 'GameHistoryBloc';
  final BoardRepository boardRepository;
  final GamePhaseManager gamePhaseManager;

  GameHistoryBloc({
    required this.gamePhaseManager,
    required this.boardRepository,
  }) : super(GameHistoryState()) {
    on<LoadGameHistoryEvent>(_loadGameHistoryEventHandler);
  }

  void _loadGameHistoryEventHandler(LoadGameHistoryEvent event, emit){

  }

}

class GameHistoryState {
  final List<String> records;

  GameHistoryState({this.records = const [],});
}

class LoadGameHistoryEvent {



}