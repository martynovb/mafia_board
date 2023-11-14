import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_state.dart';

class GameResultsPage extends StatefulWidget {
  const GameResultsPage({Key? key}) : super(key: key);

  @override
  State<GameResultsPage> createState() => _GameResultsPageState();
}

class _GameResultsPageState extends State<GameResultsPage> {
  late GameResultsBloc gameResultsBloc;

  @override
  void initState() {
    gameResultsBloc = GetIt.I.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.defaultSidePadding),
        child: BlocConsumer(
          bloc: gameResultsBloc,
          listener: (context, GameResultsState state) {},
          builder: (context, GameResultsState state) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
