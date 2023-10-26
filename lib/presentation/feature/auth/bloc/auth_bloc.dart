import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/repo/auth_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/field_validation/email_validator.dart';
import 'package:mafia_board/domain/field_validation/password_validator.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_event.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _tag = 'AuthBloc';
  final AuthRepo authRepo;
  final EmailFieldValidator emailFieldValidator;
  final PasswordFieldValidator passwordFieldValidator;

  AuthBloc({
    required this.authRepo,
    required this.emailFieldValidator,
    required this.passwordFieldValidator,
  }) : super(InitialAuthState()) {
    on<LoginAuthEvent>(_loginEventHandler);
    on<LogoutAuthEvent>(_logoutEventHandler);
    on<RegistrationAuthEvent>(_registrationEventHandler);
    on<MeAuthEvent>(_meEventHandler);
  }

  Future<void> _loginEventHandler(LoginAuthEvent event, emit) async {
    try {
      emailFieldValidator.validate(event.email);
      passwordFieldValidator.validate(event.password);
      emit(InitialAuthState());
      await authRepo.loginUser(email: event.email, password: event.password);
      emit(SuccessAuthState());
    } on ValidationError catch (ex) {
      emit(ErrorAuthState(ex.errorMessage));
    } on ApiException catch (ex) {
      emit(ErrorAuthState('Network error'));
    } catch (ex) {
      emit(ErrorAuthState('Something went wrong'));
    }
  }

  Future<void> _logoutEventHandler(event, emit) async {}

  Future<void> _registrationEventHandler(event, emit) async {}

  Future<void> _meEventHandler(event, emit) async {}
}
