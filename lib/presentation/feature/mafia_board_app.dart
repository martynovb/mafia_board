import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_bloc.dart';
import 'package:mafia_board/presentation/feature/home/home_page.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_bloc/vote_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_bloc/players_sheet_bloc.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/role_bloc/role_bloc.dart';

class MafiaBoardApp extends StatelessWidget {
  const MafiaBoardApp({super.key});

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
        ],
        child: MaterialApp(
          title: 'Mafia board',
          theme: ThemeData(brightness: Brightness.dark),
          home: const HomePage(),
        ));
  }
}
