import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/manager/game_results_manager.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_event.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_state.dart';

class GameResultsBloc extends Bloc<GameResultsEvent, GameResultsState> {
  final GameResultsManager gameResultsManager;

  GameResultsBloc({
    required this.gameResultsManager,
  }) : super(InitialGameResultsState()) {
    on<SaveResultsEvent>(_saveGameResultsEventHandler);
    on<CalculateResultsEvent>(_calculateGameResultsEventHandler);
  }

  Future<void> _saveGameResultsEventHandler(
    SaveResultsEvent event,
    emit,
  ) async {
    if (event.gameResultsModel != null && event.clubModel != null) {
      await gameResultsManager.saveResults(
        clubModel: event.clubModel!,
        gameResultsModel: event.gameResultsModel!,
      );
    }
    emit(GameResultsUploaded());
  }

  Future<void> _calculateGameResultsEventHandler(
    CalculateResultsEvent event,
    emit,
  ) async {
    try {
      if (event.club == null) {
        emit(GameResultsErrorState());
      } else {
        GameResultsModel results = await gameResultsManager.getPlayersResults(
          club: event.club!,
        );
        emit(ShowGameResultsState(results));
      }
    } catch (ex) {
      emit(GameResultsErrorState(errorMessage: ex.toString()));
    }
  }
}
