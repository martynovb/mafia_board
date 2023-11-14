import 'package:bloc/bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_event.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_state.dart';

class GameResultsBloc extends Bloc<GameResultsEvent, GameResultsState> {

  GameResultsBloc(): super(InitialGameResultsState()){
    on<SaveResultsEvent>(_saveGameResultsEventHandler);
  }

  Future<void> _saveGameResultsEventHandler(SaveResultsEvent event, emit) async {

  }
}