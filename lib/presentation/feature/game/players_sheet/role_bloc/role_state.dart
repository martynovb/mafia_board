import 'package:mafia_board/domain/model/role.dart';

abstract class RoleState {}

class ShowRolesState extends RoleState {
  final Map<Role, bool> roles;

  ShowRolesState({this.roles = const {}});
}
