import 'package:collection/collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mafia_board/domain/model/winner_type.dart';
import 'package:mafia_board/domain/usecase/delete_game_usecase.dart';
import 'package:mafia_board/domain/usecase/get_all_games_usecase.dart';
import 'package:mafia_board/domain/usecase/get_club_details_usecase.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';

class ClubsDetailsBloc extends HydratedBloc<ClubsDetailsEvent, ClubState> {
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
    if ((event.club?.id == null || event.club?.id == '') &&
        state.club?.id == null) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'No club info, try to reload the details',
        ),
      );
      return;
    }

    try {
      final allGames = (await getAllGamesUsecase.execute(
        params: event.club?.id ?? state.club?.id,
      ))
          .sorted(
        (a, b) => b.startedAt.compareTo(a.startedAt),
      );

      final totalGames = allGames.length;
      final civilianWins = allGames
          .where((game) => game.winnerType == WinnerType.civilian)
          .length;
      final mafiaWins =
          allGames.where((game) => game.winnerType == WinnerType.mafia).length;

      final club = event.club;
      club?.games = allGames;
      club?.civilWinRate =
          totalGames > 0 ? (civilianWins / totalGames) * 100 : 0.0;
      club?.mafWinRate = totalGames > 0 ? (mafiaWins / totalGames) * 100 : 0.0;

      emit(state.copyWith(
        status: StateStatus.data,
        club: event.club?..games = allGames,
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

  @override
  ClubState? fromJson(Map<String, dynamic> json) {
    return ClubState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(ClubState state) {
    return state.toMap();
  }
}
