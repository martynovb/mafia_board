import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/board_repository.dart';
import 'package:mafia_board/data/game_history_repository.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/night_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_list/vote_phase_list_bloc.dart';
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
    _getIt.registerSingleton(
      NightPhaseManager(
        gamePhaseRepository: _getIt.get(),
        gameHistoryManager: _getIt.get(),
        boardRepository: _getIt.get(),
        roleManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      VotePhaseManager(
        gamePhaseRepository: _getIt.get(),
        gameHistoryManager: _getIt.get(),
        boardRepository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      SpeakingPhaseManager(
        boardRepository: _getIt.get(),
        gameHistoryManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(GamePhaseManager(
      boardRepository: _getIt.get(),
      gamePhaseRepository: _getIt.get(),
      gameHistoryManager: _getIt.get(),
      votePhaseGameManager: _getIt.get(),
      speakingPhaseManager: _getIt.get(),
      nightPhaseManager: _getIt.get(),
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
        gamePhaseManager: _getIt.get(),
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

    _getIt.registerSingleton(
      SpeakingPhaseBloc(
        gamePhaseManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      NightPhaseBloc(
        boardRepository: _getIt.get(),
        gamePhaseManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      VotePhaseListBloc(
        gamePhaseManager: _getIt.get(),
      ),
    );
  }
}
