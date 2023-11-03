import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_event.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_state.dart';

class ClubsListBloc extends Bloc<ClubsListEvent, ClubsListState> {
  static const String _tag = 'ClubsListBloc';
  final ClubsRepo clubsRepo;

  ClubsListBloc({
    required this.clubsRepo,
  }) : super(InitialClubState()) {
    on<GetAllClubsEvent>(_getAllClubsEventHandler);
    on<GetAllClubMembersEvent>(_getClubMembersEventHandler);
    on<ApproveJoinRequestEvent>(_approveJoinRequestEventHandler);
  }

  Future<void> _getAllClubsEventHandler(event, emit) async {
    emit(AllClubsState(await clubsRepo.getClubs()));
  }

  Future<void> _getClubMembersEventHandler(event, emit) async {}

  Future<void> _approveJoinRequestEventHandler(
    ApproveJoinRequestEvent event,
    emit,
  ) async {}
}
