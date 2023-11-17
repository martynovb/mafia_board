import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/phase_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_state.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_bloc.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/night_phase/night_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/vote_phase/vote_phase_table_view.dart';
import 'package:mafia_board/presentation/feature/game/phase_view/speaking_phase/speaking_phase_table_view.dart';

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
  late GameBloc gameBloc;
  late SpeakingPhaseBloc speakingPhaseBloc;
  int touchedIndex = -1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    gameBloc = GetIt.I();
    speakingPhaseBloc = GetIt.I();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
      child: BlocBuilder(
        bloc: gameBloc,
        builder: (BuildContext context, GameState state) {
          if (state is InitialGameState ||
              (state is GamePhaseState &&
                  state.currentGame?.gameStatus != GameStatus.inProgress)) {
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
        bloc: gameBloc,
        builder: (BuildContext context, GameState state) {
          if (state is GamePhaseState) {
            if (state.currentGame?.currentDayInfo.currentPhase == PhaseType.speak) {
              speakingPhaseBloc.add(GetCurrentSpeakPhaseEvent());
              return SpeakingPhaseTableView(
                  onSpeechFinished: () => gameBloc.add(NextPhaseEvent()));
            } else if (state.currentGame?.currentDayInfo.currentPhase == PhaseType.vote) {
              return VotePhaseTableView(
                  onVoteFinished: () => gameBloc.add(NextPhaseEvent()));
            } else if (state.currentGame?.currentDayInfo.currentPhase == PhaseType.night) {
              return NightPhaseTableView(
                  onNightPhaseFinished: () => gameBloc.add(NextPhaseEvent()));
            }
          }
          return Container();
        });
  }

  Widget _header(GameState state) {
    if (state is GamePhaseState && state.currentGame?.gameStatus == GameStatus.inProgress) {
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
    return Container();
  }

  Widget _finishGameButton() => GestureDetector(
      onTap: () {
        widget.onGameFinished();
      },
      child: const Text(
        'Finish Game',
        style: TextStyle(fontSize: 22),
      ));
}
