import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/repo/board/board_repo.dart';
import 'package:mafia_board/data/repo/board/board_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/game_phase/speak_phase_repo/speak_phase_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/vote_phase_repo/vote_phase_repo_local.dart';
import 'package:mafia_board/data/repo/history/history_repository.dart';
import 'package:mafia_board/data/repo/history/history_repository_local.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo_local.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/night_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/domain/player_manager.dart';
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
      SpeakPhaseRepoLocal(),
      instanceName: speakPhaseRepoLocalTag,
    );

    _getIt.registerSingleton<GamePhaseRepo<NightPhaseAction>>(
      BasePhaseRepoLocal(),
      instanceName: nightPhaseRepoLocalTag,
    );

    _getIt.registerSingleton<HistoryRepository>(HistoryRepositoryLocal());
    _getIt.registerSingleton<BoardRepo>(BoardRepoLocal());
    _getIt.registerSingleton(RoleManager.classic(_getIt.get()));
    _getIt.registerSingleton(PlayerValidator());
    _getIt.registerSingleton<GameInfoRepo>(GameInfoRepoLocal());
  }

  static void _injectDomainLayer() {
    _getIt.registerSingleton(
      GameHistoryManager(
        boardRepo: _getIt.get(),
        repository: _getIt.get(),
      ),
    );
    _getIt.registerSingleton(
      NightPhaseManager(
        gameInfoRepo: _getIt.get(),
        nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        gameHistoryManager: _getIt.get(),
        boardRepository: _getIt.get(),
        roleManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      VotePhaseManager(
        gameInfoRepo: _getIt.get(),
        voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        gameHistoryManager: _getIt.get(),
        boardRepository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      SpeakingPhaseManager(
        gameInfoRepo: _getIt.get(),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        boardRepository: _getIt.get(),
        gameHistoryManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(PlayerManager(
      boardRepo: _getIt.get(),
      voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
      speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
      gameInfoRepo: _getIt.get(),
    ));

    _getIt.registerSingleton(GameManager(
      boardRepository: _getIt.get(),
      gameInfoRepo: _getIt.get(),
      gameHistoryManager: _getIt.get(),
      votePhaseGameManager: _getIt.get(),
      voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
      speakingPhaseManager: _getIt.get(),
      speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
      nightPhaseManager: _getIt.get(),
      nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
      playerManager: _getIt.get(),
    ));
  }

  static void _injectBloC() {
    _getIt.registerSingleton(
      BoardBloc(
        votePhaseManager: _getIt.get(),
        gameManager: _getIt.get(),
        boardRepository: _getIt.get(),
        playerValidator: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      PlayersSheetBloc(
        gamePhaseManager: _getIt.get(),
        boardRepository: _getIt.get(),
        gameHistoryManager: _getIt.get(),
        playerManager: _getIt.get(),
        roleManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      RoleBloc(
        roleManager: RoleManager.classic(_getIt.get()),
      ),
    );

    _getIt.registerSingleton(
      VotePhaseBloc(
        gamePhaseManager: _getIt.get(),
        votePhaseManager: _getIt.get(),
        speakingPhaseManager: _getIt.get(),
        boardRepository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      GameHistoryBloc(
        gameHistoryManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      SpeakingPhaseBloc(
        boardRepo: _getIt.get(),
        speakingPhaseManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      NightPhaseBloc(
        gamePhaseManager: _getIt.get(),
        nightPhaseManager: _getIt.get(),
        boardRepository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      VotePhaseListBloc(
        gameManager: _getIt.get(),
        votePhaseManager: _getIt.get(),
      ),
    );
  }
}
