import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/repo/board/board_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/game_phase/vote_phase_repo/vote_phase_repo_local.dart';
import 'package:mafia_board/data/repo/history/history_repository.dart';
import 'package:mafia_board/data/repo/history/history_repository_local.dart';
import 'package:mafia_board/data/game_phase_repository.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo_local.dart';
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

  static const votePhaseRepoLocalTag = 'vote-phase-repo-local';
  static const speakPhaseRepoLocalTag = 'speak-phase-repo-local';
  static const nightPhaseRepoLocalTag = 'night-phase-repo-local';

  static void inject() {
    _injectDataLayer();
    _injectDomainLayer();
    _injectBloC();
  }

  static void _injectDataLayer() {
    _getIt.registerSingleton<GamePhaseRepo<VotePhaseAction>>(
      VotePhaseRepoLocal(),
      instanceName: votePhaseRepoLocalTag,
    );

    _getIt.registerSingleton<GamePhaseRepo<SpeakPhaseAction>>(
      BasePhaseRepoLocal(),
      instanceName: speakPhaseRepoLocalTag,
    );

    _getIt.registerSingleton<GamePhaseRepo<NightPhaseAction>>(
      BasePhaseRepoLocal(),
      instanceName: nightPhaseRepoLocalTag,
    );

    _getIt.registerSingleton<HistoryRepository>(HistoryRepositoryLocal());
    _getIt.registerSingleton<BoardRepo>(BoardRepoLocal());
    _getIt.registerSingleton(GamePhaseRepository());
    _getIt.registerSingleton(RoleManager.classic(_getIt.get()));
    _getIt.registerSingleton(PlayerValidator());
    _getIt.registerSingleton<GameInfoRepo>(GameInfoRepoLocal());
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
