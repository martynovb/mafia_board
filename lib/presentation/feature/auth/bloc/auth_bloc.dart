import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/repo/auth_repo.dart';
import 'package:mafia_board/domain/exceptions/exception.dart';
import 'package:mafia_board/domain/field_validation/email_validator.dart';
import 'package:mafia_board/domain/field_validation/nickname_field_validator.dart';
import 'package:mafia_board/domain/field_validation/password_validator.dart';
import 'package:mafia_board/domain/field_validation/repeat_password_validator.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_event.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _tag = 'AuthBloc';
  final AuthRepo authRepo;
  final EmailFieldValidator emailFieldValidator;
  final NicknameFieldValidator nicknameFieldValidator;
  final PasswordFieldValidator passwordFieldValidator;
  final RepeatPasswordFieldValidator repeatPasswordFieldValidator;

  AuthBloc({
    required this.authRepo,
    required this.nicknameFieldValidator,
    required this.emailFieldValidator,
    required this.passwordFieldValidator,
    required this.repeatPasswordFieldValidator,
  }) : super(InitialAuthState()) {
    on<LoginAuthEvent>(_loginEventHandler);
    on<LogoutAuthEvent>(_logoutEventHandler);
    on<RegistrationAuthEvent>(_registrationEventHandler);
    on<MeAuthEvent>(_meEventHandler);
    on<ClearAuthEvent>(_clearEventHandler);
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

  Future<void> _logoutEventHandler(event, emit) async {
    try {
      await authRepo.logout();
      emit(LogoutSuccessAuthState());
    } on ValidationError catch (ex) {
      emit(ErrorAuthState(ex.errorMessage));
    } on ApiException catch (ex) {
      emit(ErrorAuthState('Network error'));
    } catch (ex) {
      emit(ErrorAuthState('Something went wrong'));
    }
  }

  Future<void> _registrationEventHandler(
      RegistrationAuthEvent event, emit) async {
    try {
      nicknameFieldValidator.validate(event.nickname);
      emailFieldValidator.validate(event.email);
      passwordFieldValidator.validate(event.password);
      repeatPasswordFieldValidator.validate(event.repeatPassword);
      repeatPasswordFieldValidator.validateRepeatPassword(
          event.password, event.repeatPassword);
      emit(InitialAuthState());
      await authRepo.registerUser(
          nickname: event.nickname,
          email: event.email,
          password: event.password);
      emit(SuccessAuthState());
    } on ValidationError catch (ex) {
      emit(ErrorAuthState(ex.errorMessage));
    } on ApiException catch (ex) {
      emit(ErrorAuthState('Network error'));
    } catch (ex) {
      emit(ErrorAuthState('Something went wrong'));
    }
  }

  Future<void> _meEventHandler(event, emit) async {}

  Future<void> _clearEventHandler(event, emit) async {
    emit(InitialAuthState());
  }
}
