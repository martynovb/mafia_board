import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/domain/game_phase_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/role_bloc/role_bloc.dart';

class Injector {
  static final _getIt = GetIt.instance;

  static void inject() {
    _injectDataLayer();
    _injectDomainLayer();
    _injectBloC();
  }

  static void _injectDataLayer() {
    _getIt.registerSingleton(BoardRepository());
    _getIt.registerSingleton(GamePhaseRepository());
    _getIt.registerSingleton(RoleManager.classic(_getIt.get()));
    _getIt.registerSingleton(PlayerValidator());
  }

  static void _injectDomainLayer() {
    _getIt.registerSingleton(GamePhaseManager(
      boardRepository: _getIt.get(),
      gamePhaseRepository: _getIt.get(),
    ));
  }

  static void _injectBloC() {
    _getIt.registerSingleton(
      BoardBloc(
        gamePhaseManager: _getIt.get(),
        boardRepository: _getIt.get(),
        playerValidator: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      PlayersSheetBloc(
        boardRepository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      RoleBloc(
        roleManager: RoleManager.classic(_getIt.get()),
      ),
    );
  }
}
