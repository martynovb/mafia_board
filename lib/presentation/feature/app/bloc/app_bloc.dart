import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/api/google_client_manager.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_event.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  static const String _tag = 'AppBloc';
  final AuthRepo authRepo;
  final GoogleClientManager googleClientManager;

  AppBloc({
    required this.authRepo,
    required this.googleClientManager,
  }) : super(InitialAppState()) {
    on<IsAuthorizedAppEvent>(_isAuthorizedEventHandler);
  }

  Future<void> _isAuthorizedEventHandler(event, emit) async {
    final isAuthorized = await authRepo.isAuthorized();
    if(isAuthorized){
      MafLogger.d(_tag, 'Refresh google auth');
      googleClientManager.fetchGoogleHttpClient();
    }
    emit(AppState(language: 'en', isAuthorized: isAuthorized));
  }
}
