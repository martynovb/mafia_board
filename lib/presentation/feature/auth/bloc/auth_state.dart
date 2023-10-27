abstract class AuthState {}

class InitialAuthState extends AuthState {}

class ErrorAuthState extends AuthState {
  final String errorMessage;

  ErrorAuthState(this.errorMessage);
}

class SuccessAuthState extends AuthState {}
class LogoutSuccessAuthState extends AuthState {}

class MeAuthState extends AuthState {
  final String username;
  final String email;

  MeAuthState({required this.username, required this.email});
}
