abstract class UserEvent {}

class GetUserDataEvent extends UserEvent {}

class ChangeNicknameEvent extends UserEvent {
  final String nickname;

  ChangeNicknameEvent(this.nickname);

}
