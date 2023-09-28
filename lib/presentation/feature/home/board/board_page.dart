import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/game_phase/vote_phase_action.dart';
import 'package:mafia_board/data/model/game_phase_model.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';

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
        if (!gamePhaseState.phase.isSpeakPhaseFinished())
          _speakingPhaseView(gamePhaseState.phase)
        else if (!gamePhaseState.phase.isVotingPhaseFinished())
          _votingPhaseView(gamePhaseState.phase)
        else if (!gamePhaseState.phase.isNightPhaseFinished())
          _nightPhaseView(gamePhaseState.phase)
      ],
    );
  }

  Widget _speakingPhaseView(GamePhaseModel phase) {
    return Column(
      children: [
        Text(
          'Speaking player: ${phase.getCurrentSpeakPhase()?.player?.nickname}',
        ),
        IconButton(
            onPressed: () {
              boardBloc.add(NextPhaseEvent());
            },
            icon: const Icon(Icons.play_arrow))
      ],
    );
  }

  Widget _votingPhaseView(GamePhaseModel phase) {
    return Column(children: [
      Text(
        'Vote against player: ${phase.getCurrentVotePhase()?.playerOnVote.nickname}',
      ),
      SizedBox(
        height: 16,
      ),
      Divider(),
      const Text('All players on voting:'),
      ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return _voteItem(index, phase.getUniqueTodaysVotePhases()[index]);
        },
        itemCount: phase.getUniqueTodaysVotePhases().length,
      )
    ]);
  }

  Widget _nightPhaseView(GamePhaseModel phase) {
    return Container(
      child: Text('Night phase'),
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

  Widget _voteItem(int index, VotePhaseAction votePhaseAction) {
    return Container(
        child: Row(
      children: [
        Text('${index + 1}'),
        Divider(),
        SizedBox(
          width: 8,
        ),
        Text(votePhaseAction.playerOnVote.nickname),
      ],
    ));
  }
}
