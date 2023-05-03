import 'package:mafia_board/data/model/role.dart';

class RoleModel {
  Role role;
  int count;

  RoleModel({
    this.role = Role.NONE,
    this.count = 0,
  });

  RoleModel.none()
      : role = Role.NONE,
        count = 0;
}
