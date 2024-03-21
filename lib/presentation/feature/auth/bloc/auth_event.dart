abstract class AuthEvent {}

class MeAuthEvent extends AuthEvent {}
class ClearAuthEvent extends AuthEvent {}
class LogoutAuthEvent extends AuthEvent {}

class GoogleLoginAuthEvent extends AuthEvent {}

class LoginAuthEvent extends AuthEvent {
  final String email;
  final String password;

  LoginAuthEvent({
    required this.email,
    required this.password,
  });
}

class RegistrationAuthEvent extends AuthEvent {
  final String email;
  final String nickname;
  final String password;
  final String repeatPassword;

  RegistrationAuthEvent({
    required this.email,
    required this.nickname,
    required this.password,
    required this.repeatPassword,
  });
}
