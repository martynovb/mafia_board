import 'package:bloc/bloc.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/constants.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_event.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_state.dart';

class PlayersSheetBloc extends Bloc<SheetEvent, SheetState> {
  final BoardRepository boardRepository;

  PlayersSheetBloc({required this.boardRepository})
      : super(ShowSheetState(boardRepository.getAllPlayers())) {
    on<AddFoulEvent>(_addFoulHandler);
    on<ChangeRoleEvent>(_changeRoleHandler);
    on<ChangeNicknameEvent>(_changeNicknameHandler);
  }

  void _addFoulHandler(AddFoulEvent event, emit) async {
    if (event.newFoulsCount > Constants.maxFouls) return;

    boardRepository.updatePlayer(
      event.playerId,
      fouls: event.newFoulsCount,
      isRemoved: event.newFoulsCount >= Constants.maxFouls,
    );
    emit(ShowSheetState(boardRepository.getAllPlayers()));
  }

  void _changeRoleHandler(ChangeRoleEvent event, emit) async {
    boardRepository.updatePlayer(
      event.playerId,
      role: roleMapper(event.newRole),
    );
    emit(ShowSheetState(boardRepository.getAllPlayers()));
  }

  void _changeNicknameHandler(ChangeNicknameEvent event, emit) async {
    boardRepository.updatePlayer(
      event.playerId,
      nickname: event.newNickname,
    );
    emit(ShowSheetState(boardRepository.getAllPlayers()));
  }
}
