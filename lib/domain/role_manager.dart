import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/repo/board/board_repo_local.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/data/model/role_model.dart';

class RoleManager {
  final BoardRepo _boardRepository;
  final List<RoleModel> _allRoles;
  List<Role> _selectedRoles = [];
  Map<Role, bool> _uniqueAvailableRoles = {};

  RoleManager.classic(this._boardRepository)
      : _allRoles = [
          RoleModel(role: Role.NONE, count: 10),
          RoleModel(role: Role.DON, count: 1, nightPriority: 2),
          RoleModel(role: Role.MAFIA, count: 2, nightPriority: 1),
          RoleModel(role: Role.CIVILIAN, count: 6),
          RoleModel(role: Role.SHERIFF, count: 1, nightPriority: 3),
        ] {
    _calculateAvailableRoles();
    _createPlayers();
  }

  Map<Role, bool> get availableRoles => _uniqueAvailableRoles;

  void recalculateAvailableRoles(int index, Role selectedRole) {
    _selectedRoles[index] = selectedRole;
    for (RoleModel roleModel in _allRoles) {
      if (roleModel.role == Role.NONE) {
        continue;
      }
      final selectedRoleCount = _selectedRoles
          .where(
            (selectedRole) => selectedRole == roleModel.role,
          )
          .length;
      _uniqueAvailableRoles.update(
        roleModel.role,
        (value) => selectedRoleCount < roleModel.count,
      );
    }
  }

  void _calculateAvailableRoles() {
    final List<Role> allAvailableRoles = [Role.NONE];
    _selectedRoles = [Role.NONE];
    for (RoleModel roleModel in _allRoles) {
      if (roleModel.role == Role.NONE) {
        continue;
      }
      for (var i = 0; i < roleModel.count; i++) {
        allAvailableRoles.add(roleModel.role);
        _selectedRoles.add(Role.NONE);
      }
    }

    allAvailableRoles.toSet().forEach((role) {
      _uniqueAvailableRoles.putIfAbsent(role, () => true);
    });
  }

  void _createPlayers() {
    int playersCount = 0;
    for (var roleModel in _allRoles) {
      if (roleModel.role != Role.NONE) {
        playersCount += roleModel.count;
      }
    }
    _boardRepository.createPlayers(playersCount);
  }

  List<RoleModel> get allRoles => _allRoles;
}
