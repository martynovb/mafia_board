import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_state.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/dialogs.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class TablePage extends StatefulWidget {
  final Function() onGameFinished;

  const TablePage({
    super.key,
    required this.onGameFinished,
  });

  @override
  State<StatefulWidget> createState() => _TableState();
}

class _TableState extends State<TablePage> with AutomaticKeepAliveClientMixin {
  final timerKey = GlobalKey<GameTimerViewState>();
  late GameBloc boardBloc;
  int touchedIndex = -1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    boardBloc = GetIt.I();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
      child: BlocBuilder(
        bloc: boardBloc,
        builder: (BuildContext context, GameState state) {
          if (state is InitialBoardState ||
              (state is GamePhaseState &&
                  state.dayInfo?.isGameStarted == false)) {
            return const Center(
              child: Text('Game is not started'),
            );
          }
          return Column(
            children: [
              _header(state),
              const Divider(),
              _centerTableContent(),
            ],
          );
        },
      ),
    );
  }

  Widget _centerTableContent() {
    return BlocBuilder(
        bloc: boardBloc,
        builder: (BuildContext context, GameState state) {
          if (state is GamePhaseState) {
            if (state.dayInfo?.currentPhase == PhaseType.speak) {
              return SpeakingPhaseTableView(
                  onSpeechFinished: () => boardBloc.add(NextPhaseEvent()));
            } else if (state.dayInfo?.currentPhase == PhaseType.vote) {
              return VotePhaseTableView(
                  onVoteFinished: () => boardBloc.add(NextPhaseEvent()));
            } else if (state.dayInfo?.currentPhase == PhaseType.night) {
              return NightPhaseTableView(
                  onNightPhaseFinished: () => boardBloc.add(NextPhaseEvent()));
            }
          }
          return Container();
        });
  }

  Widget _header(GameState state) {
    if (state is GamePhaseState && state.dayInfo?.isGameStarted == true) {
      return SizedBox(
          height: Dimensions.headerHeight,
          child: Row(
            children: [
              GameTimerView(key: timerKey),
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
        widget.onGameFinished();
      },
      child: const Text(
        'Finish Game',
        style: TextStyle(fontSize: 22),
      ));

  Widget _startGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(StartGameEvent());
      },
      child: const Text(
        'Start Game',
        style: TextStyle(fontSize: 32),
      ));
}
