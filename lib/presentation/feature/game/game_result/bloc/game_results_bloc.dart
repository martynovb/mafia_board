import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/domain/manager/game_results_manager.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_event.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_state.dart';

class GameResultsBloc extends HydratedBloc<GameResultsEvent, GameResultsState> {
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
    try {
      if (event.gameResultsModel != null && event.clubModel != null) {
        await gameResultsManager.saveResults(
          clubModel: event.clubModel!,
          gameResultsModel: event.gameResultsModel!,
        );
        emit(GameResultsUploaded(club: event.clubModel));
      } else {
        emit(
          GameResultsErrorState(
            club: event.clubModel,
            errorMessage: 'Not enough data to save results',
          ),
        );
      }
    } catch (ex) {
      emit(GameResultsErrorState(
        club: event.clubModel,
        errorMessage: ex.toString(),
      ));
    }
  }

  Future<void> _calculateGameResultsEventHandler(
    CalculateResultsEvent event,
    emit,
  ) async {
    try {
      if (event.club == null) {
        emit(GameResultsErrorState(
            club: event.club, errorMessage: 'No club info'));
      } else {
        GameResultsModel results = await gameResultsManager.getPlayersResults(
          club: event.club!,
        );
        emit(ShowGameResultsState(gameResultsModel: results, club: event.club));
      }
    } catch (ex) {
      emit(GameResultsErrorState(errorMessage: ex.toString()));
    }
  }

  @override
  GameResultsState? fromJson(Map<String, dynamic> json) {
    return InitialGameResultsState(club: json['club']);
  }

  @override
  Map<String, dynamic>? toJson(GameResultsState state) {
    return {
      'club': state.club,
    };
  }
}
