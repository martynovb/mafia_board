abstract class AuthState {}

class InitialAuthState extends AuthState {}

class MeAuthState extends AuthState {
  final String username;
  final String email;

  MeAuthState({required this.username, required this.email});
}
