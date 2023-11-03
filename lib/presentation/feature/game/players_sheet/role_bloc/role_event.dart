abstract class RoleEvent {}

class RecalculateRolesEvent extends RoleEvent {
  final int seatNumber;
  final String selectedRole;

  RecalculateRolesEvent(this.seatNumber, this.selectedRole);
}
