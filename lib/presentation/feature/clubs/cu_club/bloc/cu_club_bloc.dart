import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/create_club_usecase.dart';
import 'package:mafia_board/domain/usecase/update_club_usecase.dart';
import 'package:mafia_board/presentation/feature/clubs/cu_club/bloc/cu_club_event.dart';
import 'package:mafia_board/presentation/feature/clubs/cu_club/bloc/cu_club_state.dart';

class CuClubBloc extends Bloc<ClubEvent, ClubState> {
  static const String _tag = 'ClubsDetailsBloc';
  final CreateClubUseCase createClubUseCase;
  final UpdateClubUseCase updateClubUseCase;

  CuClubBloc({
    required this.createClubUseCase,
    required this.updateClubUseCase,
  }) : super(InitialClubState()) {
    on<CreateClubEvent>(_createClubEventHandler);
    on<UpdateClubEvent>(_updateClubEventHandler);
  }

  Future<void> _updateClubEventHandler(
    UpdateClubEvent event,
    emit,
  ) async {
    try {
      final club = await updateClubUseCase.execute(
        params: UpdateClubParams(
          id: event.id,
          name: event.name,
          description: event.description,
        ),
      );
    } catch (e) {
      emit(ErrorClubState('Something went wrong'));
    }
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
    } catch (e) {
      emit(ErrorClubState('Something went wrong'));
    }
  }
}
