import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/night_phase_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/speaking_phase_view.dart';
import 'package:mafia_board/presentation/feature/home/phase_view/vote_phase/vote_phase_view.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late BoardBloc boardBloc;

  @override
  void initState() {
    boardBloc = GetIt.instance<BoardBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: boardBloc,
        builder: (BuildContext context, BoardState state) {
          return Column(
            children: [
              _startGameButton(),
              _stageBoard(state),
            ],
          );
        });
  }

  Widget _errorView(String errorMessage) {
    return Text(
      errorMessage,
      style: const TextStyle(
          color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _stageBoard(BoardState state) {
    if (state is GamePhaseState) {
      return Center(child: _gamePhaseView(state));
    } else if (state is ErrorBoardState) {
      return _errorView(state.errorMessage);
    } else {
      return const Center(
        child: Text(
          'Empty',
        ),
      );
    }
  }

  Widget _gamePhaseView(GamePhaseState gamePhaseState) {
    return Column(
          children: [
            Text('DAY #${gamePhaseState.phase.currentDay}'),
            Text('Title: ${gamePhaseState.currentGamePhaseName}'),
            _getPhaseView(gamePhaseState),
          ],
        );
  }

  Widget _getPhaseView(GamePhaseState gamePhaseState) {
    if (!gamePhaseState.phase.isSpeakPhaseFinished()) {
      return SpeakingPhaseView(
        currentPhase: gamePhaseState.phase.getCurrentSpeakPhase(),
        onNextPressed: () => boardBloc.add(
          NextPhaseEvent(),
        ),
      );
    } else if (!gamePhaseState.phase.isVotingPhaseFinished()) {
      return const SingleChildScrollView(child: VotePhaseView());
    } else if (!gamePhaseState.phase.isNightPhaseFinished()) {
      return const NightPhaseView();
    } else {
      return Container();
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
}
