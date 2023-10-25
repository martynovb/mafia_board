import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/auth_repo.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_event.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  static const String _tag = 'AppBloc';
  final AuthRepo authRepo;

  AppBloc({
    required this.authRepo,
  }) : super(InitialAppState()) {
    on<IsAuthorizedAppEvent>(_isAuthorizedEventHandler);
  }

  Future<void> _isAuthorizedEventHandler(event, emit) async {
    emit(AppState(language: 'en', isAuthorized: await authRepo.isAuthorized()));
  }
}
