abstract class RoleEvent {}

class RecalculateRolesEvent extends RoleEvent {
  final int index;
  final String selectedRole;

  RecalculateRolesEvent(this.index, this.selectedRole);
}
