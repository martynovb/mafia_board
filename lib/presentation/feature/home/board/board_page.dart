import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  var isGameStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    boardBloc = BlocProvider.of<BoardBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: boardBloc,
        builder: (BuildContext context, BoardState state) {
          if (state is StartGameState) {
            isGameStarted = true;
          }
          return Column(
            children: [
              _stageBoard(),
              state is ErrorBoardState
                  ? _errorView(state.errorMessage)
                  : Container()
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

  Widget _stageBoard() {
    return Center(
      child: _startGameButton(),
    );
  }

  Widget _startGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(StartGameEvent());
      },
      child: Text(
        isGameStarted ? 'GAME STARTED' : 'Start Game',
        style: TextStyle(fontSize: 32),
      ));
}
