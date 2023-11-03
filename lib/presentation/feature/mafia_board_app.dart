import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_bloc.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_event.dart';
import 'package:mafia_board/presentation/feature/app/bloc/app_state.dart';
import 'package:mafia_board/presentation/feature/auth/bloc/auth_bloc.dart';
import 'package:mafia_board/presentation/feature/auth/login_page.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_bloc.dart';
import 'package:mafia_board/presentation/feature/home/game_page.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_list/vote_phase_list_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/role_bloc/role_bloc.dart';
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
          BlocProvider(create: (context) => GetIt.instance<BoardBloc>()),
          BlocProvider(create: (context) => GetIt.instance<VotePhaseBloc>()),
          BlocProvider(create: (context) => GetIt.instance<GameHistoryBloc>()),
          BlocProvider(create: (context) => GetIt.instance<SpeakingPhaseBloc>()),
          BlocProvider(create: (context) => GetIt.instance<NightPhaseBloc>()),
          BlocProvider(create: (context) => GetIt.instance<VotePhaseListBloc>()),
          BlocProvider(create: (context) => GetIt.instance<AuthBloc>()),
          BlocProvider(create: (context) => GetIt.instance<AppBloc>()),
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
                      ? const GamePage()
                      : const LoginPage(),
              routes: AppRouter.routes,
            );
          },
        ));
  }
}
