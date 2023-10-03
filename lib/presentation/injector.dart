import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_history_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/game_phase_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
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
    _getIt.registerSingleton(GameHistoryRepository());
    _getIt.registerSingleton(BoardRepository());
    _getIt.registerSingleton(GamePhaseRepository());
    _getIt.registerSingleton(RoleManager.classic(_getIt.get()));
    _getIt.registerSingleton(PlayerValidator());
  }

  static void _injectDomainLayer() {
    _getIt.registerSingleton(
      GameHistoryManager(
        repository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(GamePhaseManager(
      boardRepository: _getIt.get(),
      gamePhaseRepository: _getIt.get(),
      gameHistoryManager: _getIt.get(),
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
        gameHistoryManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      RoleBloc(
        roleManager: RoleManager.classic(_getIt.get()),
      ),
    );

    _getIt.registerSingleton(
      VotePhaseBloc(
        boardRepository: _getIt.get(),
        gamePhaseManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      GameHistoryBloc(
        gameHistoryManager: _getIt.get(),
      ),
    );
  }
}
