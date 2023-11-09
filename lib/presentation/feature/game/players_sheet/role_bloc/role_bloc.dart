import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_event.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_state.dart';

class RoleBloc extends Bloc<RoleEvent, ShowRolesState> {
  final RoleManager roleManager;

  RoleBloc({required this.roleManager}) : super(ShowRolesState()) {
    emit(ShowRolesState(
      roles: roleManager.uniqueAvailableRoles,
    ));
    on<RecalculateRolesEvent>(_recalculateAvailableRolesHandler);
  }

  void _recalculateAvailableRolesHandler(
    RecalculateRolesEvent event,
    emit,
  ) async {
    roleManager.recalculateAvailableRoles(
        event.seatNumber, roleMapper(event.selectedRole));
    emit(ShowRolesState(
      roles: roleManager.uniqueAvailableRoles,
    ));
  }
}
