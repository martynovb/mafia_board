import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/create_club_usecase.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_event.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_state.dart';

class CreateClubBloc extends Bloc<CreateClubEvent, CreateClubState> {
  final CreateClubUseCase createClubUseCase;

  CreateClubBloc({
    required this.createClubUseCase,
  }) : super(InitialClubState()) {
    on<CreateClubEvent>(_createClubEventHandler);
  }

  Future<void> _createClubEventHandler(
    CreateClubEvent event,
    emit,
  ) async {
    try {
      final club = await createClubUseCase.execute(
        params: CreateClubParams(
          name: event.name,
          clubDescription: event.clubDescription,
        ),
      );
      emit(ClubCreatedState(club));
    } catch (e) {
      emit(ErrorClubState('Something went wrong'));
    }
  }
}
