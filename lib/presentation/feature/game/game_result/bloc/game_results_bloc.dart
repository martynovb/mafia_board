import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/domain/manager/game_flow/game_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_results_manager.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_event.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_state.dart';

class GameResultsBloc extends HydratedBloc<GameResultsEvent, GameResultsState> {
  final GameManager gameManager;
  final GameResultsManager gameResultsManager;

  GameResultsBloc({
    required this.gameManager,
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
      if (event.gameResultsModel != null && state.club != null) {
        await gameResultsManager.saveResults(
          clubModel: state.club!,
          gameResultsModel: event.gameResultsModel!,
        );
        await gameManager.resetGameData();
        emit(GameResultsUploaded(club: state.club));
      } else {
        emit(
          GameResultsErrorState(
            club: state.club,
            errorMessage: 'Not enough data to save results',
          ),
        );
      }
    } catch (ex) {
      emit(GameResultsErrorState(
        club: state.club,
        errorMessage: ex.toString(),
      ));
    }
  }

  Future<void> _calculateGameResultsEventHandler(
    CalculateResultsEvent event,
    emit,
  ) async {
    try {
      if ((event.club?.id == null || event.club?.id == '') &&
          state.club?.id == null) {
        emit(
          GameResultsErrorState(
            errorMessage: 'No club info',
          ),
        );
        return;
      } else {
        emit(InitialGameResultsState(club: event.club ?? state.club));
        GameResultsModel results = await gameResultsManager.getPlayersResults(
          club: event.club!,
        );
        emit(
          ShowGameResultsState(
            gameResultsModel: results,
            club: state.club,
          ),
        );
      }
    } catch (ex) {
      emit(GameResultsErrorState(errorMessage: ex.toString()));
    }
  }

  @override
  GameResultsState? fromJson(Map<String, dynamic> json) {
    return InitialGameResultsState(club: ClubModel.fromMap(json['club']));
  }

  @override
  Map<String, dynamic>? toJson(GameResultsState state) {
    return {
      'club': state.club?.toMap(),
    };
  }
}
