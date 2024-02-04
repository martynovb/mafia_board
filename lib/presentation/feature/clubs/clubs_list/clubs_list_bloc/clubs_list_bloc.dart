import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/get_all_clubs_usecase.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_event.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_state.dart';

class ClubsListBloc extends Bloc<ClubsListEvent, ClubsListState> {
  static const String _tag = 'ClubsListBloc';
  final GetAllClubsUseCase getAllClubsUseCase;

  ClubsListBloc({
    required this.getAllClubsUseCase,
  }) : super(ClubsListState(status: StateStatus.inProgress)) {
    on<GetAllClubsEvent>(_getAllClubsEventHandler);
  }

  Future<void> _getAllClubsEventHandler(event, emit) async {
    emit(state.copyWith(status: StateStatus.inProgress));
    try {
      emit(
        state.copyWith(
          status: StateStatus.data,
          clubs: await getAllClubsUseCase.execute(),
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(
            status: StateStatus.error, errorMessage: "Can't load clubs"),
      );
    }
  }
}
