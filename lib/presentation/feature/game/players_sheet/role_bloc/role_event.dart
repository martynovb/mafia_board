import 'package:mafia_board/domain/model/role.dart';

abstract class RoleEvent {}

class ResetRolesEvent extends RoleEvent {}

class RecalculateRolesEvent extends RoleEvent {
  final int seatNumber;
  final Role selectedRole;

  RecalculateRolesEvent(this.seatNumber, this.selectedRole);
}
