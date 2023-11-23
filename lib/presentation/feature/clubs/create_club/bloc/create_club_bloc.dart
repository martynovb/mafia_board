import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/create_club_usecase.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_event.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_state.dart';

class CreateClubBloc extends Bloc<CreateClubEvent, CreateClubState> {
  static const String _tag = 'CreateClubBloc';
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
          description: event.description,
        ),
      );
      emit(ClubCreatedState(club.id));
    } catch (e) {
      emit(ErrorClubState('Something went wrong'));
    }
  }
}
