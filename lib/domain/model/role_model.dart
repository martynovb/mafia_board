import 'package:mafia_board/domain/model/role.dart';

class RoleModel {
  Role role;
  int count;
  int nightPriority;

  RoleModel({
    this.role = Role.none,
    this.count = 0,
    this.nightPriority = -1,
  });

  RoleModel.none()
      : role = Role.none,
        count = 0,
        nightPriority = -1;
}
