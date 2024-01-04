import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/domain/usecase/change_nickname_usecase.dart';
import 'package:mafia_board/domain/usecase/get_user_data_usecase.dart';
import 'package:mafia_board/presentation/feature/settings/bloc/user_event.dart';
import 'package:mafia_board/presentation/feature/settings/bloc/user_state.dart';
import 'package:mafia_board/presentation/maf_logger.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  static const String _tag = 'UserBloc';
  final GetUserDataUseCase getUserDataUseCase;
  final ChangeNicknameUseCase changeNicknameUseCase;

  UserBloc({
    required this.changeNicknameUseCase,
    required this.getUserDataUseCase,
  }) : super(InitialState()) {
    on<GetUserDataEvent>(_getUserDataEventHandler);
    on<ChangeNicknameEvent>(_changeNicknameEventHandler);
  }

  Future<void> _getUserDataEventHandler(event, emit) async {
    try {
      final user = await getUserDataUseCase.execute();
      if (user != null) {
        emit(UserDataState(userModel: user));
      }
    } catch (e) {
      MafLogger.e(_tag, e.toString());
    }
  }

  Future<void> _changeNicknameEventHandler(
    ChangeNicknameEvent event,
    emit,
  ) async {
    try {
      final user = await changeNicknameUseCase.execute(params: event.nickname);
      if (user != null) {
        emit(UserDataState(userModel: user));
      }
    } on ValidationException catch (ex) {
      final user = await getUserDataUseCase.execute();
      if (user != null) {
        emit(UserDataState(
          userModel: user,
          errorMessage: ex.message,
        ));
      }
    } catch (e) {
      MafLogger.e(_tag, e.toString());
    }
  }
}
