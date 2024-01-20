import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/usecase/get_all_users_usecase.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_event.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_state.dart';

class UserListBloc extends Bloc<FetchUserListEvent, UserListState> {
  final GetAllUsersUsecase getAllUsersUsecase;

  UserListBloc({
    required this.getAllUsersUsecase,
  }) : super(UserListState()) {
    on<FetchUserListEvent>(_fetchUserListEventHandler);
  }

  Future<void> _fetchUserListEventHandler(event, emit) async {
    try {
      emit(UserListState(users: await getAllUsersUsecase.execute()));
    } catch (ex){
      emit(UserListState());
    }
  }
}
