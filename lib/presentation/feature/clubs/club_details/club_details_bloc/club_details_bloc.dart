import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_event.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_state.dart';

class ClubsDetailsBloc extends Bloc<ClubsDetailsEvent, ClubDetailsState> {
  static const String _tag = 'ClubsDetailsBloc';
  final ClubsRepo clubsRepo;

  ClubsDetailsBloc({
    required this.clubsRepo,
  }) : super(InitialState()) {
    on<GetClubDetailsEvent>(_getClubDetailsEventHandler);
  }

  Future<void> _getClubDetailsEventHandler(
      GetClubDetailsEvent event, emit) async {
    if (event.clubId.isEmpty) {
      emit(InitialState());
      return;
    }

    final result = await clubsRepo.getClubDetails(id: event.clubId);
    emit(
      result != null ? DetailsState(result) : InitialState(),
    );
  }
}
