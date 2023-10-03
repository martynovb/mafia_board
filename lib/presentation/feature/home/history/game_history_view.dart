import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/game_history_model.dart';
import 'package:mafia_board/data/model/game_history_type.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_bloc.dart';

class GameHistoryView extends StatefulWidget {
  const GameHistoryView({Key? key}) : super(key: key);

  @override
  State<GameHistoryView> createState() => _GameHistoryViewState();
}

class _GameHistoryViewState extends State<GameHistoryView> {
  late GameHistoryBloc gameHistoryBloc;

  @override
  void initState() {
    gameHistoryBloc = GetIt.instance<GameHistoryBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    gameHistoryBloc.add(SubscribeToGameHistoryEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: gameHistoryBloc,
        builder: (context, GameHistoryState state) {
          return Column(
            children: [
              const Divider(),
              const Text('Game logs:'),
              const SizedBox(height: 8),
              Expanded(child: _voteList(state.records)),
            ],
          );
        });
  }

  Widget _voteList(List<GameHistoryModel> history) => ListView.builder(
        itemBuilder: (context, index) {
          return _voteItem(index, history[index]);
        },
        itemCount: history.length,
      );

  Widget _voteItem(int index, GameHistoryModel record) {
    TextStyle style;
    switch (record.type) {
      case GameHistoryType.startGame:
      case GameHistoryType.finishGame:
        style = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
        break;
      case GameHistoryType.newDay:
        style = const TextStyle(fontWeight: FontWeight.bold);
        break;
      default:
        style = const TextStyle();
        break;
    }

    return Text(
      record.text,
      style: style,
    );
  }
}
