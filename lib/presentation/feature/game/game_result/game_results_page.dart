import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/game_results_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_event.dart';
import 'package:mafia_board/presentation/feature/game/game_result/bloc/game_results_state.dart';

class GameResultsPage extends StatefulWidget {
  const GameResultsPage({Key? key}) : super(key: key);

  @override
  State<GameResultsPage> createState() => _GameResultsPageState();
}

class _GameResultsPageState extends State<GameResultsPage> {
  late GameResultsBloc gameResultsBloc;
  late String clubId;

  final int _voteColumnFlex = 0;
  final int _nicknameColumnFlex = 5;
  final int _roleColumnFlex = 5;
  final int _scoreColumnFlex = 2;

  @override
  void initState() {
    gameResultsBloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    clubId = args?['clubId'] ?? '';
    gameResultsBloc.add(CalculateResultsEvent(clubId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                gameResultsBloc.add(CalculateResultsEvent(clubId));
              },
              icon: const Icon(
                Icons.refresh,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.defaultSidePadding),
        child: BlocConsumer(
          bloc: gameResultsBloc,
          listener: (context, GameResultsState state) {},
          builder: (context, GameResultsState state) {
            if (state is ShowGameResultsState) {
              return Column(
                children: [
                  _tableHeader(),
                  _playersTable(state.gameResultsModel),
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
        padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
        height: Dimensions.playerSheetHeaderHeight,
        child: Row(
          children: [
            Expanded(
              flex: _voteColumnFlex,
              child: const Padding(
                  padding: EdgeInsets.only(
                    left: Dimensions.sidePadding0_5x,
                  ),
                  child: Icon(
                    Icons.numbers,
                    size: Dimensions.defaultIconSize,
                  )),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _nicknameColumnFlex,
              child: const Center(child: Text('nickname')),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _roleColumnFlex,
              child: const Center(child: Text('role')),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _scoreColumnFlex,
              child: const Center(child: Text('total')),
            ),
          ],
        ));
  }

  Widget _playersTable(GameResultsModel results) => Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white30),
            borderRadius: const BorderRadius.all(Radius.circular(0))),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.players.length,
          separatorBuilder: (context, index) => const Divider(
            height: Dimensions.sidePadding0_5x,
          ),
          itemBuilder: (__, index) => _playerItem(
            index,
            results.players[index],
          ),
        ),
      );

  Widget _playerItem(int index, PlayerModel player) {
    return SizedBox(
      height: Dimensions.playerItemHeight,
      child: Row(
        children: [
          Expanded(
            flex: _voteColumnFlex,
            child: SizedBox(
              width: Dimensions.defaultIconSize,
              height: Dimensions.defaultIconSize,
              child: Center(
                child: Text((index + 1).toString()),
              ),
            ),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _nicknameColumnFlex,
            child: Text(player.nickname),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _roleColumnFlex,
            child: Center(child: _roleIndicator(player.role)),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _scoreColumnFlex,
            child: Center(child: Text(player.score.toString())),
          ),
        ],
      ),
    );
  }

  Widget _roleIndicator(Role role) {
    return Text(role.name);
  }
}
