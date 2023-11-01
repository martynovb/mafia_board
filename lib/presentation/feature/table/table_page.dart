import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/speaking_phase/speaking_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<StatefulWidget> createState() => _TableState();
}

class _TableState extends State<TablePage> {
  late BoardBloc boardBloc;
  int touchedIndex = -1;

  @override
  void initState() {
    boardBloc = GetIt.I();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
    body: Padding(
      padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
      child: BlocBuilder(
        bloc: boardBloc,
        builder: (BuildContext context, BoardState state) {
          return Column(
            children: [
              _header(state),
              const Divider(),
              _centerTableContent(),
            ],
          );
        },
      ),
    ));
  }

  Widget _centerTableContent() {
    return BlocBuilder(
        bloc: boardBloc,
        builder: (BuildContext context, BoardState state) {
          if (state is GamePhaseState) {
            if (state.gameInfo?.currentPhase == PhaseType.speak) {
              return SpeakingPhaseTableView(
                  onSpeechFinished: () => boardBloc.add(NextPhaseEvent()));
            } else if (state.gameInfo?.currentPhase == PhaseType.vote) {
              return VotePhaseTableView(
                  onVoteFinished: () => boardBloc.add(NextPhaseEvent()));
            } else if (state.gameInfo?.currentPhase == PhaseType.night) {
              return NightPhaseTableView(
                  onNightPhaseFinished: () => boardBloc.add(NextPhaseEvent()));
            }
          }
          return Container();
        });
  }

  Widget _header(BoardState state) {
    if (state is GamePhaseState && state.gameInfo?.isGameStarted == true) {
      return SizedBox(
          height: Dimensions.headerHeight,
          child: Row(
            children: [
              const GameTimerView(),
              const Spacer(),
              _finishGameButton(),
            ],
          ));
    }
    return SizedBox(
        height: Dimensions.headerHeight,
        child: Center(
          child: _startGameButton(),
        ));
  }

  Widget _finishGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(FinishGameEvent());
      },
      child: const Text(
        'Finish Game',
        style: TextStyle(fontSize: 22),
      ));

  Widget _errorView(String errorMessage) {
    return InfoField(
      message: errorMessage,
      infoFieldType: InfoFieldType.error,
    );
  }

  Widget _startGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(StartGameEvent());
      },
      child: const Text(
        'Start Game',
        style: TextStyle(fontSize: 32),
      ));
}
