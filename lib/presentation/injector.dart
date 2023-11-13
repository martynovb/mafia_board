import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/api/auth_api.dart';
import 'package:mafia_board/data/api/base_url_provider.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/api/http_client.dart';
import 'package:mafia_board/data/api/network_manager.dart';
import 'package:mafia_board/data/api/token_provider.dart';
import 'package:mafia_board/data/repo/rules/rules_local_repo.dart';
import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_action.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_action.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/auth/auth_repo_local.dart';
import 'package:mafia_board/data/repo/auth/auth_repo_remote.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo_local.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/game_phase/speak_phase_repo/speak_phase_repo_local.dart';
import 'package:mafia_board/data/repo/game_phase/vote_phase_repo/vote_phase_repo_local.dart';
import 'package:mafia_board/data/repo/history/history_repository.dart';
import 'package:mafia_board/data/repo/history/history_repository_local.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_info_repo_local.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo_local.dart';
import 'package:mafia_board/domain/field_validation/email_validator.dart';
import 'package:mafia_board/domain/field_validation/nickname_field_validator.dart';
import 'package:mafia_board/domain/field_validation/password_validator.dart';
import 'package:mafia_board/domain/field_validation/repeat_password_validator.dart';
import 'package:mafia_board/domain/game_history_manager.dart';
import 'package:mafia_board/domain/phase_manager/game_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/night_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/speaking_phase_manager.dart';
import 'package:mafia_board/domain/phase_manager/vote_phase_manager.dart';
import 'package:mafia_board/domain/player_manager.dart';
import 'package:mafia_board/domain/player_validator.dart';
import 'package:mafia_board/domain/role_manager.dart';
import 'package:mafia_board/domain/usecase/get_all_clubs_usecase.dart';
import 'package:mafia_board/domain/usecase/get_club_details_usecase.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/update_rules_usecase.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/history/game_history_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_phase_list_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_bloc.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_bloc.dart';

class Injector {
  static final _getIt = GetIt.instance;

  static const votePhaseRepoLocalTag = 'vote-phase-repo-local';
  static const speakPhaseRepoLocalTag = 'speak-phase-repo-local';
  static const nightPhaseRepoLocalTag = 'night-phase-repo-local';

  static void inject(bool isLocalDataBase) {
    _injectDataLayer(isLocalDataBase);
    _injectDomainLayer();
    _injectBloC();
  }

  static void _injectDataLayer(bool isLocalDataBase) {
    //network
    _getIt.registerSingleton<BaseUrlProvider>(LocalBaseUrlProvider());
    _getIt.registerSingleton<TokenProvider>(TokenProvider());
    _getIt.registerSingleton<ErrorHandler>(ErrorHandler(
      tokenProvider: _getIt.get(),
    ));
    _getIt.registerSingleton<HttpClient>(HttpClient(
      tokenProvider: _getIt.get(),
      baseUrlProvider: _getIt.get(),
    ));

    _getIt.registerSingleton<NetworkManager>(NetworkManager(
      httpClient: _getIt.get(),
      errorHandler: _getIt.get(),
    ));

    _getIt.registerSingleton<AuthApi>(AuthApi(_getIt.get()));

    //repo
    _getIt.registerSingleton<AuthRepo>(
      isLocalDataBase
          ? AuthRepoLocal()
          : AuthRepoRemote(
              api: _getIt.get(),
              tokenProvider: _getIt.get(),
            ),
    );

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

    _getIt.registerSingleton<HistoryRepo>(HistoryRepoLocal());
    _getIt.registerSingleton<PlayersRepo>(PlayersRepoLocal());
    _getIt.registerSingleton(RoleManager.classic(_getIt.get()));
    _getIt.registerSingleton(PlayerValidator());
    _getIt.registerSingleton<GameInfoRepo>(GameInfoRepoLocal());
    _getIt.registerSingleton<UsersRepo>(UsersRepoLocal(authRepo: _getIt.get()));
    _getIt.registerSingleton<ClubsRepo>(ClubsRepoLocal(
      authRepo: _getIt.get(),
      usersRepo: _getIt.get(),
    ));

    _getIt.registerSingleton<RulesRepo>(RulesLocalRepo(
      _getIt.get(),
    ));
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

    //usecase
    _getIt.registerSingleton<GetAllClubsUseCase>(
        GetAllClubsUseCase(clubsRepo: _getIt.get()));
    _getIt.registerSingleton<GetClubDetailsUseCase>(GetClubDetailsUseCase(
      authRepo: _getIt.get(),
      clubsRepo: _getIt.get(),
    ));
    _getIt.registerSingleton<GetRulesUseCase>(
        GetRulesUseCase(rulesRepo: _getIt.get()));
    _getIt.registerSingleton<UpdateRulesUseCase>(
        UpdateRulesUseCase(rulesRepo: _getIt.get()));

    //validation
    _getIt.registerSingleton<NicknameFieldValidator>(NicknameFieldValidator());
    _getIt.registerSingleton<RepeatPasswordFieldValidator>(
        RepeatPasswordFieldValidator());
    _getIt.registerSingleton<PasswordFieldValidator>(PasswordFieldValidator());
    _getIt.registerSingleton<EmailFieldValidator>(EmailFieldValidator());
  }

  static void _injectBloC() {
    _getIt.registerSingleton(
      GameBloc(
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
        RoleBloc(roleManager: RoleManager.classic(_getIt.get())));

    _getIt.registerSingleton(
      VotePhaseBloc(
        gamePhaseManager: _getIt.get(),
        votePhaseManager: _getIt.get(),
        speakingPhaseManager: _getIt.get(),
        boardRepository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(GameHistoryBloc(gameHistoryManager: _getIt.get()));

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

    _getIt.registerSingleton(AuthBloc(
      nicknameFieldValidator: _getIt.get(),
      emailFieldValidator: _getIt.get(),
      passwordFieldValidator: _getIt.get(),
      repeatPasswordFieldValidator: _getIt.get(),
      authRepo: _getIt.get(),
    ));

    _getIt.registerSingleton(AppBloc(authRepo: _getIt.get()));
    _getIt.registerSingleton(ClubsListBloc(getAllClubsUseCase: _getIt.get()));
    _getIt.registerSingleton(
        ClubsDetailsBloc(getClubDetailsUseCase: _getIt.get()));
    _getIt.registerSingleton(GameRulesBloc(
      updateRulesUseCase: _getIt.get(),
      getRulesUseCase: _getIt.get(),
    ));
  }
}
