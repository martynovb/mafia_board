import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/model/game_history_model.dart';
import 'package:mafia_board/data/model/game_history_type.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_bloc.dart';

class GameHistoryPage extends StatefulWidget  {
  const GameHistoryPage({Key? key}) : super(key: key);

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> with AutomaticKeepAliveClientMixin {
  late GameHistoryBloc gameHistoryBloc;

  @override
  bool get wantKeepAlive => true;

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
    return Padding(
        padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
        child: BlocBuilder(
            bloc: gameHistoryBloc,
            builder: (context, GameHistoryState state) {
              if (state.records.isEmpty) {
                return const Center(
                  child: Text('History is empty'),
                );
              }
              return Column(
                children: [
                  const Text('Game logs:'),
                  const SizedBox(height: 8),
                  Expanded(child: _voteList(state.records)),
                ],
              );
            }));
  }

  Widget _voteList(List<GameHistoryModel> history) => ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        shrinkWrap: true,
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

    if (record.subText.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.text,
            style: style,
          ),
          Text(
            record.subText,
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    return Text(
      record.text,
      style: style,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
