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
    final results = event.gameResultsModel;
    if(results != null) {
      await gameResultsManager.saveResults(
          gameResultsModel: results);
    }
    emit(GameResultsUploaded());
  }

  Future<void> _calculateGameResultsEventHandler(
    CalculateResultsEvent event,
    emit,
  ) async {
    GameResultsModel results = await gameResultsManager.getPlayersResults(
      clubId: event.clubId,
    );
    emit(ShowGameResultsState(results));
  }
}
