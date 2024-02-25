import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_event.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepo authRepo;

  AppBloc({
    required this.authRepo,
  }) : super(InitialAppState()) {
    on<IsAuthorizedAppEvent>(_isAuthorizedEventHandler);
  }

  Future<void> _isAuthorizedEventHandler(event, emit) async {
    final isAuthorized = await authRepo.isAuthorized();
    emit(AppState(language: 'en', isAuthorized: isAuthorized));
  }
}
