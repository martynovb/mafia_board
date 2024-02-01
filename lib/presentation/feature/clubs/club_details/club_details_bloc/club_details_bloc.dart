import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/club_model.dart';
import 'package:mafia_board/domain/usecase/get_all_games_usecase.dart';
import 'package:mafia_board/domain/usecase/get_club_details_usecase.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';

class ClubsDetailsBloc extends Bloc<ClubsDetailsEvent, ClubDetailsState> {
  static const String _tag = 'ClubsDetailsBloc';
  final GetClubDetailsUseCase getClubDetailsUseCase;
  final GetAllGamesUsecase getAllGamesUsecase;
  ClubModel? currentClub;

  ClubsDetailsBloc({
    required this.getClubDetailsUseCase,
    required this.getAllGamesUsecase,
  }) : super(InitialState()) {
    on<GetClubDetailsEvent>(_getClubDetailsEventHandler);
  }

  Future<void> _getClubDetailsEventHandler(
    GetClubDetailsEvent event,
    emit,
  ) async {
    if (event.club.id.isEmpty) {
      emit(InitialState());
      return;
    }

    currentClub = event.club;

    try {
      final clubWithDetails =
          await getClubDetailsUseCase.execute(params: event.club);
      final allGames = await getAllGamesUsecase.execute(params: event.club.id);

      emit(
        DetailsState(
          club: clubWithDetails,
          allGames: allGames,
        ),
      );

    } catch (e) {
      emit(ErrorClubState('Something went wrong'));
    }
  }
}
