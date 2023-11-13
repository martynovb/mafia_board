import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/get_all_clubs_usecase.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_event.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_state.dart';

class ClubsListBloc extends Bloc<ClubsListEvent, ClubsListState> {
  static const String _tag = 'ClubsListBloc';
  final GetAllClubsUseCase getAllClubsUseCase;

  ClubsListBloc({
    required this.getAllClubsUseCase,
  }) : super(InitialClubState()) {
    on<GetAllClubsEvent>(_getAllClubsEventHandler);
    on<GetAllClubMembersEvent>(_getClubMembersEventHandler);
    on<ApproveJoinRequestEvent>(_approveJoinRequestEventHandler);
  }

  Future<void> _getAllClubsEventHandler(event, emit) async {
    emit(AllClubsState(await getAllClubsUseCase.execute()));
  }

  Future<void> _getClubMembersEventHandler(event, emit) async {}

  Future<void> _approveJoinRequestEventHandler(
    ApproveJoinRequestEvent event,
    emit,
  ) async {}
}
