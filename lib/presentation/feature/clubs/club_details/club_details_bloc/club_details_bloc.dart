import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/get_club_details_usecase.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';

class ClubsDetailsBloc extends Bloc<ClubsDetailsEvent, ClubDetailsState> {
  static const String _tag = 'ClubsDetailsBloc';
  final GetClubDetailsUseCase getClubDetailsUseCase;

  ClubsDetailsBloc({
    required this.getClubDetailsUseCase,
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

    try {
      final result = await getClubDetailsUseCase.execute(params: event.club);
      emit(DetailsState(result));
    } catch (e) {
      emit(ErrorClubState('Something went wrong'));
    }
  }
}
