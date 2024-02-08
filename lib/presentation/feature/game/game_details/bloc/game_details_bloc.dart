import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/domain/usecase/fetch_game_details_usecase.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/game/game_details/bloc/game_details_event.dart';
import 'package:mafia_board/presentation/feature/game/game_details/bloc/game_details_state.dart';

class GameDetailsBloc extends HydratedBloc<GameDetailsEvent, GameDetailsState> {
  final FetchGameDetailsUseCase fetchGameDetailsUseCase;

  GameDetailsBloc({
    required this.fetchGameDetailsUseCase,
  }) : super(GameDetailsState(status: StateStatus.inProgress)) {
    on<GetGameDetailsEvent>(_getGameDetailsEventHandler);
  }

  Future<void> _getGameDetailsEventHandler(
    GetGameDetailsEvent event,
    emit,
  ) async {
    if (event.gameId == null ||
        event.gameId!.isEmpty ||
        event.gameId == state.gameId) {
      return;
    }
    emit(state.copyWith(status: StateStatus.inProgress));
    try {
      final gameDetails =
          await fetchGameDetailsUseCase.execute(params: event.gameId);
      emit(
        state.copyWith(
          status: StateStatus.data,
          gameDetails: gameDetails,
          gameId: event.gameId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'Something went wrong',
        ),
      );
    }
  }

  @override
  GameDetailsState? fromJson(Map<String, dynamic> json) {
    try {
      return GameDetailsState.fromMap(json);
    } catch (ex) {
      return GameDetailsState(
        status: StateStatus.error,
        errorMessage: ex.toString(),
      );
    }
  }

  @override
  Map<String, dynamic>? toJson(GameDetailsState state) {
    try {
      return state.toMap();
    } catch (ex) {
      return {
        'status': StateStatus.inProgress,
      };
    }
  }

  @override
  Future<void> clear() {
    return super.clear();
  }
}
