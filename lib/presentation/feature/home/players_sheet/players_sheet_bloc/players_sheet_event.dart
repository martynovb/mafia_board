abstract class SheetEvent {}

class AddFoulEvent extends SheetEvent {
  final int playerId;
  final int newFoulsCount;

  AddFoulEvent({
    required this.playerId,
    required this.newFoulsCount,
  });
}

class ChangeRoleEvent extends SheetEvent {
  final int playerId;
  final String? newRole;

  ChangeRoleEvent({
    required this.playerId,
    required this.newRole,
  });
}

class ChangeNicknameEvent extends SheetEvent {
  final int playerId;
  final String? newNickname;

  ChangeNicknameEvent({
    required this.playerId,
    required this.newNickname,
  });
}

class KillPlayerHandler extends SheetEvent {
  final int playerId;

  KillPlayerHandler({required this.playerId});
}
