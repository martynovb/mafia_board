import 'package:mafia_board/domain/model/role.dart';

class RoleModel {
  Role role;
  int count;
  int nightPriority;

  RoleModel({
    this.role = Role.NONE,
    this.count = 0,
    this.nightPriority = -1,
  });

  RoleModel.none()
      : role = Role.NONE,
        count = 0,
        nightPriority = -1;
}
