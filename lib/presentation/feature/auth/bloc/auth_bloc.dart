import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/auth_repo.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_event.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _tag = 'AuthBloc';
  final AuthRepo authRepo;

  AuthBloc({
    required this.authRepo,
  }) : super(InitialAuthState()) {
    on<LoginAuthEvent>(_loginEventHandler);
    on<LogoutAuthEvent>(_logoutEventHandler);
    on<RegistrationAuthEvent>(_registrationEventHandler);
    on<MeAuthEvent>(_meEventHandler);
  }

  Future<void> _loginEventHandler(event, emit) async {

  }

  Future<void> _logoutEventHandler(event, emit) async {

  }

  Future<void> _registrationEventHandler(event, emit) async {

  }

  Future<void> _meEventHandler(event, emit) async {

  }
}
