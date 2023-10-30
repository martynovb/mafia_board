abstract class SheetEvent {}

class FindUserEvent extends SheetEvent {
  final int seatNumber;

  FindUserEvent({required this.seatNumber});
}

class AddFoulEvent extends SheetEvent {
  final String playerId;
  final int newFoulsCount;

  AddFoulEvent({
    required this.playerId,
    required this.newFoulsCount,
  });
}

class ChangeRoleEvent extends SheetEvent {
  final String playerId;
  final String? newRole;

  ChangeRoleEvent({
    required this.playerId,
    required this.newRole,
  });
}

class ChangeNicknameEvent extends SheetEvent {
  final String playerId;
  final String? newNickname;

  ChangeNicknameEvent({
    required this.playerId,
    required this.newNickname,
  });
}

class SetTestDataEvent extends SheetEvent {
}

class KillPlayerHandler extends SheetEvent {
  final String playerId;

  KillPlayerHandler({required this.playerId});
}
