import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/usecase/delete_game_usecase.dart';
import 'package:mafia_board/domain/usecase/get_all_games_usecase.dart';
import 'package:mafia_board/domain/usecase/get_club_details_usecase.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';

class ClubsDetailsBloc extends Bloc<ClubsDetailsEvent, ClubState> {
  static const String _tag = 'ClubsDetailsBloc';
  final GetClubDetailsUseCase getClubDetailsUseCase;
  final GetAllGamesUsecase getAllGamesUsecase;
  final DeleteGameUseCase deleteGameUseCase;

  ClubsDetailsBloc({
    required this.getClubDetailsUseCase,
    required this.getAllGamesUsecase,
    required this.deleteGameUseCase,
  }) : super(ClubState(status: StateStatus.inProgress)) {
    on<GetClubDetailsEvent>(_getClubDetailsEventHandler);
    on<DeleteGameEvent>(_deleteGameEventHandler);
  }

  Future<void> _deleteGameEventHandler(DeleteGameEvent event, emit) async {
    emit(state.copyWith(status: StateStatus.inProgress));
    try {
      await deleteGameUseCase.execute(params: event.gameId);
      emit(
        state.copyWith(
          status: StateStatus.data,
          allGames: state.allGames
            ..removeWhere((game) => game.id == event.gameId),
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'Something went wrong',
        ),
      );
    }
  }

  Future<void> _getClubDetailsEventHandler(
    GetClubDetailsEvent event,
    emit,
  ) async {
    if ((event.club?.id == null || event.club?.id == '') && state.club?.id == null) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'No club info, try to reload the details',
        ),
      );
      return;
    }

    try {
      final allGames = await getAllGamesUsecase.execute(params: event.club?.id ?? state.club?.id);
      emit(state.copyWith(
        status: StateStatus.data,
        club: event.club,
        allGames: allGames,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'No club info, try to reload the details',
        ),
      );
    }
  }
}
