import 'package:bloc/bloc.dart';
import 'package:mafia_board/domain/manager/role_manager.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_event.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_state.dart';

class RoleBloc extends Bloc<RoleEvent, ShowRolesState> {
  final RoleManager roleManager;

  RoleBloc({required this.roleManager})
      : super(
          ShowRolesState(
            roles: roleManager.uniqueAvailableRoles,
          ),
        ) {
    on<RecalculateRolesEvent>(_recalculateAvailableRolesHandler);
    on<ResetRolesEvent>(_onResetRoles);
  }

  void _recalculateAvailableRolesHandler(
    RecalculateRolesEvent event,
    emit,
  ) async {
    roleManager.recalculateAvailableRoles(
      event.seatNumber,
      event.selectedRole,
    );
    emit(ShowRolesState(
      roles: roleManager.uniqueAvailableRoles,
    ));
  }

void _onResetRoles(event, emit) async {
    roleManager.resetAvailableRoles();
    emit(ShowRolesState(
      roles: roleManager.uniqueAvailableRoles,
    ));
  }

}
