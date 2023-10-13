import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/phase_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase/night_phase_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/speaking_phase/speaking_phase_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_view.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late BoardBloc boardBloc;
  final double _headerHeight = 32;

  @override
  void initState() {
    boardBloc = GetIt.instance<BoardBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(Dimensions.smallSidePadding),
        child: BlocBuilder(
            bloc: boardBloc,
            builder: (BuildContext context, BoardState state) {
              return Column(
                children: [
                  _header(state),
                  const Divider(),
                  _stageBoard(state),
                ],
              );
            }));
  }

  Widget _errorView(String errorMessage) {
    return Text(
      errorMessage,
      style: const TextStyle(
          color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _stageBoard(BoardState state) {
    if (state is InitialBoardState ||
        state is ErrorBoardState ||
        (state is GamePhaseState && state.gameInfo?.isGameFinished == true)) {
      return Center(
        child: _startGameButton(),
      );
    } else if (state is GamePhaseState &&
        state.gameInfo?.isGameFinished == false) {
      return Center(child: _gamePhaseView(state));
    } else if (state is ErrorBoardState) {
      return _errorView(state.errorMessage);
    } else {
      return Container();
    }
  }

  Widget _gamePhaseView(GamePhaseState gamePhaseState) {
    return Column(
      children: [
        Text('DAY #${gamePhaseState.gameInfo?.day}'),
        Text('Title: ${gamePhaseState.currentGamePhaseName}'),
        _getPhaseView(gamePhaseState),
      ],
    );
  }

  Widget _getPhaseView(GamePhaseState gamePhaseState) {
    if (gamePhaseState.gameInfo?.currentPhase == PhaseType.speak) {
      return SpeakingPhaseView(
          onSpeechFinished: () => boardBloc.add(NextPhaseEvent()));
    } else if (gamePhaseState.gameInfo?.currentPhase == PhaseType.vote) {
      return const VotePhaseView();
    } else if (gamePhaseState.gameInfo?.currentPhase == PhaseType.night) {
      return NightPhaseView(
          onNightPhaseFinished: () => boardBloc.add(NextPhaseEvent()));
    } else {
      return Container();
    }
  }

  Widget _header(BoardState state) {
    if (state is GamePhaseState && state.gameInfo?.isGameFinished == false) {
      return SizedBox(
          height: _headerHeight,
          child: Row(
            children: [
              const GameTimerView(),
              const Spacer(),
              _finishGameButton(),
            ],
          ));
    } else {
      return SizedBox(
        height: _headerHeight,
        child: state is ErrorBoardState ? _errorView(state.errorMessage) : null,
      );
    }
  }

  Widget _startGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(StartGameEvent());
      },
      child: const Text(
        'Start Game',
        style: TextStyle(fontSize: 32),
      ));

  Widget _finishGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(FinishGameEvent());
      },
      child: const Text(
        'Finish Game',
        style: TextStyle(fontSize: 32),
      ));
}
