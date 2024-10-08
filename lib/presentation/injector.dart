import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/api/error_handler.dart';
import 'package:mafia_board/data/repo/auth/auth_repo_firebase.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo_firebase.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo_firebase.dart';
import 'package:mafia_board/data/repo/rules/rules_repo.dart';
import 'package:mafia_board/data/repo/rules/rules_repo_firebase.dart';
import 'package:mafia_board/domain/manager/game_flow_simulator.dart';
import 'package:mafia_board/domain/manager/game_results_manager.dart';
import 'package:mafia_board/domain/model/game_phase/night_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/game_phase/vote_phase_model.dart';
import 'package:mafia_board/data/repo/auth/auth_repo.dart';
import 'package:mafia_board/data/repo/auth/auth_repo_local.dart';
import 'package:mafia_board/data/repo/auth/users/users_repo.dart';
import 'package:mafia_board/data/repo/clubs/clubs_repo.dart';
import 'package:mafia_board/data/repo/game_phase/base_phase_repo.dart';
import 'package:mafia_board/data/repo/game_phase/game_phase_repo.dart';
import 'package:mafia_board/data/repo/game_phase/speak_phase_repo/speak_phase_repo.dart';
import 'package:mafia_board/data/repo/game_phase/vote_phase_repo/vote_phase_repo.dart';
import 'package:mafia_board/data/repo/history/history_repository.dart';
import 'package:mafia_board/data/repo/history/history_repository_local.dart';
import 'package:mafia_board/data/repo/game_info/game_repo.dart';
import 'package:mafia_board/data/repo/game_info/game_repo_impl.dart';
import 'package:mafia_board/data/repo/players/players_repo.dart';
import 'package:mafia_board/data/repo/players/players_repo_impl.dart';
import 'package:mafia_board/domain/field_validation/email_validator.dart';
import 'package:mafia_board/domain/field_validation/nickname_field_validator.dart';
import 'package:mafia_board/domain/field_validation/password_validator.dart';
import 'package:mafia_board/domain/field_validation/repeat_password_validator.dart';
import 'package:mafia_board/domain/manager/game_history_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/game_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/night_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/speaking_phase_manager.dart';
import 'package:mafia_board/domain/manager/game_flow/vote_phase_manager.dart';
import 'package:mafia_board/domain/manager/player_manager.dart';
import 'package:mafia_board/domain/usecase/change_nickname_usecase.dart';
import 'package:mafia_board/domain/usecase/create_club_members_usecase.dart';
import 'package:mafia_board/domain/usecase/create_club_usecase.dart';
import 'package:mafia_board/domain/usecase/create_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/delete_game_usecase.dart';
import 'package:mafia_board/domain/usecase/fetch_game_details_usecase.dart';
import 'package:mafia_board/domain/usecase/get_all_games_usecase.dart';
import 'package:mafia_board/domain/usecase/get_all_users_usecase.dart';
import 'package:mafia_board/domain/usecase/get_club_rating_usecase.dart';
import 'package:mafia_board/domain/usecase/get_user_data_usecase.dart';
import 'package:mafia_board/domain/usecase/save_game_usecase.dart';
import 'package:mafia_board/domain/validator/player_validator.dart';
import 'package:mafia_board/domain/manager/role_manager.dart';
import 'package:mafia_board/domain/usecase/create_day_info_usecase.dart';
import 'package:mafia_board/domain/usecase/create_game_usecase.dart';
import 'package:mafia_board/domain/usecase/finish_game_usecase.dart';
import 'package:mafia_board/domain/usecase/get_all_clubs_usecase.dart';
import 'package:mafia_board/domain/usecase/get_club_details_usecase.dart';
import 'package:mafia_board/domain/usecase/get_current_game_usecase.dart';
import 'package:mafia_board/domain/usecase/get_last_day_info_usecase.dart';
import 'package:mafia_board/domain/usecase/get_last_valid_day_info_usecase.dart';
import 'package:mafia_board/domain/usecase/get_rules_usecase.dart';
import 'package:mafia_board/domain/usecase/remove_game_data_usecase.dart';
import 'package:mafia_board/domain/usecase/update_day_info_usecase.dart';
import 'package:mafia_board/domain/usecase/update_rules_usecase.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/create_club/bloc/create_club_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/rating_table/bloc/rating_table_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_details/bloc/game_details_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_bloc.dart';
import 'package:mafia_board/presentation/feature/game/history/game_history_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_phase_list_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_bloc.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_bloc.dart';
import 'package:mafia_board/presentation/feature/game/users/bloc/user_list_bloc.dart';
import 'package:mafia_board/presentation/feature/settings/bloc/user_bloc.dart';

class Injector {
  static final _getIt = GetIt.instance;

  static const votePhaseRepoLocalTag = 'vote-phase-repo-local';
  static const speakPhaseRepoLocalTag = 'speak-phase-repo-local';
  static const nightPhaseRepoLocalTag = 'night-phase-repo-local';

  static Future<void> inject({bool mockDb = false}) async {
    await _injectDataLayer(mockDb);
    _injectDomainLayer();
    _injectPresentation();
  }

  static Future<void> _injectDataLayer(bool isLocalDataBase) async {
    //network
    _getIt.registerSingleton<ErrorHandler>(ErrorHandler());

    _getIt.registerSingleton<AuthRepo>(
      isLocalDataBase
          ? AuthRepoLocal()
          : AuthRepoFirebase(
              firebaseAuth: FirebaseAuth.instance,
              firestore: FirebaseFirestore.instance,
            ),
    );

    _getIt.registerSingleton<GamePhaseRepo>(
        BasePhaseRepo(firestore: FirebaseFirestore.instance));

    _getIt.registerSingleton<GamePhaseRepo<VotePhaseModel>>(
      VotePhaseRepo(firestore: FirebaseFirestore.instance),
      instanceName: votePhaseRepoLocalTag,
    );

    _getIt.registerSingleton<GamePhaseRepo<SpeakPhaseModel>>(
      SpeakPhaseRepo(firestore: FirebaseFirestore.instance),
      instanceName: speakPhaseRepoLocalTag,
    );

    _getIt.registerSingleton<GamePhaseRepo<NightPhaseModel>>(
      BasePhaseRepo(firestore: FirebaseFirestore.instance),
      instanceName: nightPhaseRepoLocalTag,
    );

    _getIt.registerSingleton<HistoryRepo>(HistoryRepoLocal());
    _getIt.registerSingleton<PlayersRepo>(PlayersRepoImpl(
      firestore: FirebaseFirestore.instance,
    ));
    _getIt.registerSingleton(RoleManager.classic(_getIt.get()));
    _getIt.registerSingleton(PlayerValidator());
    _getIt.registerSingleton<GameRepo>(GameRepoImpl(
      firestore: FirebaseFirestore.instance,
    ));
    _getIt.registerSingleton<UsersRepo>(UsersRepoFirebase(
      firestore: FirebaseFirestore.instance,
    ));
    _getIt.registerSingleton<ClubsRepo>(
      ClubsRepoFirebase(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        usersRepo: _getIt.get(),
      ),
    );

    _getIt.registerSingleton<RulesRepo>(RulesRepoFirebase(
      firestore: FirebaseFirestore.instance,
    ));
  }

  static void _injectDomainLayer() {
    //usecase
    _getIt.registerSingleton(CreateClubMembersUseCase(
      playersRepo: _getIt.get(),
      clubsRepo: _getIt.get(),
    ));
    _getIt.registerSingleton<GetAllClubMembersUsecase>(
      GetAllClubMembersUsecase(clubsRepo: _getIt.get()),
    );
    _getIt.registerSingleton<ChangeNicknameUseCase>(
      ChangeNicknameUseCase(authRepo: _getIt.get()),
    );
    _getIt.registerSingleton<CreateRulesUseCase>(
      CreateRulesUseCase(rulesRepo: _getIt.get()),
    );
    _getIt.registerSingleton<CreateClubUseCase>(
      CreateClubUseCase(clubsRepo: _getIt.get()),
    );
    _getIt.registerSingleton<SaveGameUseCase>(
      SaveGameUseCase(
        gameRepo: _getIt.get(),
        createClubMembersUseCase: _getIt.get(),
        playersRepo: _getIt.get(),
        voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
      ),
    );
    _getIt.registerSingleton<GetCurrentGameUseCase>(
      GetCurrentGameUseCase(gameRepo: _getIt.get()),
    );
    _getIt.registerSingleton<FinishGameUseCase>(
      FinishGameUseCase(gameRepo: _getIt.get()),
    );
    _getIt.registerSingleton<CreateGameUseCase>(
      CreateGameUseCase(gameRepo: _getIt.get()),
    );
    _getIt.registerSingleton<UpdateDayInfoUseCase>(
      UpdateDayInfoUseCase(gameRepo: _getIt.get()),
    );
    _getIt.registerSingleton<GetLastValidDayInfoUseCase>(
      GetLastValidDayInfoUseCase(gameRepo: _getIt.get()),
    );
    _getIt.registerSingleton<GetLastDayInfoUseCase>(
      GetLastDayInfoUseCase(gameRepo: _getIt.get()),
    );
    _getIt.registerSingleton<CreateDayInfoUseCase>(
      CreateDayInfoUseCase(_getIt.get()),
    );
    _getIt.registerSingleton(GetAllClubsUseCase(clubsRepo: _getIt.get()));
    _getIt.registerSingleton(
        GetClubDetailsUseCase(authRepo: _getIt.get(), clubsRepo: _getIt.get()));
    _getIt.registerSingleton(GetRulesUseCase(rulesRepo: _getIt.get()));
    _getIt.registerSingleton(GetUserDataUseCase(authRepo: _getIt.get()));
    _getIt.registerSingleton<UpdateRulesUseCase>(
        UpdateRulesUseCase(rulesRepo: _getIt.get()));
    _getIt.registerSingleton(GetAllGamesUsecase(gameRepo: _getIt.get()));
    _getIt.registerSingleton(DeleteGameUseCase(
      gameRepo: _getIt.get(),
      playersRepo: _getIt.get(),
      voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
      speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
      nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
    ));

    _getIt.registerSingleton(FetchGameDetailsUseCase(
      gameRepo: _getIt.get(),
      playersRepo: _getIt.get(),
      gamePhaseRepo: _getIt.get(),
    ));

    _getIt.registerSingleton(GetClubRatingUseCase(
      clubsRepo: _getIt.get(),
      playersRepo: _getIt.get(),
    ));

    _getIt.registerSingleton(
      GameHistoryManager(
        boardRepo: _getIt.get(),
        repository: _getIt.get(),
      ),
    );
    _getIt.registerSingleton(
      NightPhaseManager(
        getCurrentGameUseCase: _getIt.get(),
        nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        gameHistoryManager: _getIt.get(),
        playersRepository: _getIt.get(),
        roleManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      VotePhaseManager(
        getCurrentGameUseCase: _getIt.get(),
        voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        gameHistoryManager: _getIt.get(),
        boardRepository: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      SpeakingPhaseManager(
        getCurrentGameUseCase: _getIt.get(),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        playersRepository: _getIt.get(),
        gameHistoryManager: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      PlayerManager(
        boardRepo: _getIt.get(),
        voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        getCurrentGameUseCase: _getIt.get(),
        updateDayInfoUseCase: _getIt.get(),
        createDayInfoUseCase: _getIt.get(),
      ),
    );

    _getIt.registerSingleton<RemoveGameDataUseCase>(
      RemoveGameDataUseCase(
        gameRepo: _getIt.get(),
        voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
        playersRepo: _getIt.get(),
        historyRepo: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      GameManager(
        voteGamePhaseRepo: _getIt.get(instanceName: votePhaseRepoLocalTag),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
        playersRepository: _getIt.get(),
        dayInfoRepo: _getIt.get(),
        gameHistoryManager: _getIt.get(),
        votePhaseGameManager: _getIt.get(),
        speakingPhaseManager: _getIt.get(),
        nightPhaseManager: _getIt.get(),
        playerManager: _getIt.get(),
        createDayInfoUseCase: _getIt.get(),
        updateDayInfoUseCase: _getIt.get(),
        createGameUseCase: _getIt.get(),
        getLastDayInfoUseCase: _getIt.get(),
        getCurrentGameUseCase: _getIt.get(),
        finishGameUseCase: _getIt.get(),
        removeGameDataUseCase: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      GameResultsManager(
        playersRepo: _getIt.get(),
        getRulesUseCase: _getIt.get(),
        saveGameResultsUseCase: _getIt.get(),
        speakGamePhaseRepo: _getIt.get(instanceName: speakPhaseRepoLocalTag),
        nightGamePhaseRepo: _getIt.get(instanceName: nightPhaseRepoLocalTag),
      ),
    );

    //validation
    _getIt.registerSingleton<NicknameFieldValidator>(NicknameFieldValidator());
    _getIt.registerSingleton<RepeatPasswordFieldValidator>(
        RepeatPasswordFieldValidator());
    _getIt.registerSingleton<PasswordFieldValidator>(PasswordFieldValidator());
    _getIt.registerSingleton<EmailFieldValidator>(EmailFieldValidator());

    _getIt.registerSingleton(
      GameFlowSimulator(
        gameManager: _getIt.get(),
        playersRepo: _getIt.get(),
        speakingPhaseManager: _getIt.get(),
        votePhaseManager: _getIt.get(),
      ),
    );
  }

  static void _injectPresentation() {

    _getIt.registerSingleton(
      UserBloc(
          getUserDataUseCase: _getIt.get(),
          changeNicknameUseCase: _getIt.get()),
    );

    _getIt.registerSingleton(
      GameBloc(
        votePhaseManager: _getIt.get(),
        gameManager: _getIt.get(),
        playersRepository: _getIt.get(),
        playerValidator: _getIt.get(),
        getCurrentGameUseCase: _getIt.get(),
        gameFlowSimulator: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      PlayersSheetBloc(
        gamePhaseManager: _getIt.get(),
        playersRepository: _getIt.get(),
        gameHistoryManager: _getIt.get(),
        playerManager: _getIt.get(),
        roleManager: _getIt.get(),
        getCurrentGameUseCase: _getIt.get(),
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

    _getIt.registerSingleton(
      AuthBloc(
        nicknameFieldValidator: _getIt.get(),
        emailFieldValidator: _getIt.get(),
        passwordFieldValidator: _getIt.get(),
        repeatPasswordFieldValidator: _getIt.get(),
        authRepo: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(AppBloc(
      authRepo: _getIt.get(),
    ));

    _getIt.registerSingleton(ClubsListBloc(getAllClubsUseCase: _getIt.get()));
    _getIt.registerSingleton(
      ClubsDetailsBloc(
        getClubDetailsUseCase: _getIt.get(),
        getAllGamesUsecase: _getIt.get(),
        deleteGameUseCase: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(
      GameRulesBloc(
        updateRulesUseCase: _getIt.get(),
        getRulesUseCase: _getIt.get(),
        createRulesUseCase: _getIt.get(),
      ),
    );

    _getIt.registerSingleton(GameResultsBloc(gameResultsManager: _getIt.get(), gameManager: _getIt.get()));
    _getIt.registerSingleton(CreateClubBloc(createClubUseCase: _getIt.get()));
    _getIt.registerSingleton(UserListBloc(getAllUsersUsecase: _getIt.get()));
    _getIt.registerSingleton(GameDetailsBloc(fetchGameDetailsUseCase: _getIt.get()));
    _getIt.registerSingleton(RatingTableBloc(getClubRatingUseCase: _getIt.get()));
  }
}
