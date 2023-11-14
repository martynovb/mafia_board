import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_bloc.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_event.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_state.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/login_page.dart';
import 'package:mafia_board/presentation/feature/clubs/club_details/club_details_bloc/club_details_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_bloc/clubs_list_bloc.dart';
import 'package:mafia_board/presentation/feature/clubs/clubs_list/clubs_list_page.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_bloc.dart';
import 'package:mafia_board/presentation/feature/game/history/game_history_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_list/vote_phase_list_bloc.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/role_bloc/role_bloc.dart';
import 'package:mafia_board/presentation/feature/game/rules/bloc/rules_bloc.dart';
import 'package:mafia_board/presentation/feature/router.dart';

class MafiaBoardApp extends StatefulWidget {
  const MafiaBoardApp({Key? key}) : super(key: key);

  @override
  State<MafiaBoardApp> createState() => _MafiaBoardAppState();
}

class _MafiaBoardAppState extends State<MafiaBoardApp> {
  late AppBloc appBloc;

  @override
  void initState() {
    appBloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    appBloc.add(IsAuthorizedAppEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GetIt.instance<PlayersSheetBloc>()),
          BlocProvider(create: (context) => GetIt.instance<RoleBloc>()),
          BlocProvider(create: (context) => GetIt.instance<GameBloc>()),
          BlocProvider(create: (context) => GetIt.instance<VotePhaseBloc>()),
          BlocProvider(create: (context) => GetIt.instance<GameHistoryBloc>()),
          BlocProvider(create: (context) => GetIt.instance<SpeakingPhaseBloc>()),
          BlocProvider(create: (context) => GetIt.instance<NightPhaseBloc>()),
          BlocProvider(create: (context) => GetIt.instance<VotePhaseListBloc>()),
          BlocProvider(create: (context) => GetIt.instance<AuthBloc>()),
          BlocProvider(create: (context) => GetIt.instance<AppBloc>()),
          BlocProvider(create: (context) => GetIt.instance<ClubsDetailsBloc>()),
          BlocProvider(create: (context) => GetIt.instance<ClubsListBloc>()),
          BlocProvider(create: (context) => GetIt.instance<GameRulesBloc>()),
          BlocProvider(create: (context) => GetIt.instance<GameResultsBloc>()),
        ],
        child: BlocBuilder(
          bloc: appBloc,
          builder: (context, AppState state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mafia board',
              theme: ThemeData(brightness: Brightness.dark),
              home: state is InitialAppState
                  ? Container()
                  : state.isAuthorized
                      ? const ClubsPage()
                      : const LoginPage(),
              routes: AppRouter.routes,
            );
          },
        ));
  }
}
