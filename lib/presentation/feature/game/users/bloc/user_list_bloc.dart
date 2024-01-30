import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/club_member_model.dart';
import 'package:mafia_board/domain/usecase/get_all_users_usecase.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_event.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_state.dart';

class UserListBloc extends Bloc<FetchUserListEvent, UserListState> {
  final GetAllClubMembersUsecase getAllUsersUsecase;
  String? clubId;
  List<ClubMemberModel> allPossibleClubMembers = [];

  UserListBloc({
    required this.getAllUsersUsecase,
  }) : super(UserListState()) {
    on<FetchUserListEvent>(_fetchUserListEventHandler);
  }

  Future<void> _fetchUserListEventHandler(
      FetchUserListEvent event, emit) async {
    if (clubId == event.clubId && allPossibleClubMembers.isNotEmpty) {
      emit(UserListState(clubMember: allPossibleClubMembers));
      return;
    }

    try {
      clubId = event.clubId;
      allPossibleClubMembers.addAll(
        await getAllUsersUsecase.execute(params: event.clubId),
      );
      emit(UserListState(clubMember: allPossibleClubMembers));
    } catch (ex) {
      emit(UserListState());
    }
  }
}
