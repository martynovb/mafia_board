import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/data/entity/game/day_info_entity.dart';
import 'package:mafia_board/domain/model/game_details_model.dart';
import 'package:mafia_board/domain/model/game_info_model.dart';
import 'package:mafia_board/domain/model/game_phase/speak_phase_model.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/domain/model/role.dart';
import 'package:mafia_board/presentation/common/base_bloc/base_state.dart';
import 'package:mafia_board/presentation/common/helper/game_details_view_helper.dart';
import 'package:mafia_board/presentation/common/helper/player_action_wrapper.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game/game_details/bloc/game_details_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_details/bloc/game_details_event.dart';
import 'package:mafia_board/presentation/feature/game/game_details/bloc/game_details_state.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class GameDetailsPage extends StatefulWidget {
  const GameDetailsPage({super.key});

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  late GameDetailsBloc gameDetailsBloc;
  final int _voteColumnFlex = 0;
  final int _nicknameColumnFlex = 5;
  final int _roleColumnFlex = 5;
  final int _scoreColumnFlex = 2;

  @override
  void initState() {
    gameDetailsBloc = GetIt.I.get();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final gameId = args?['gameId'] ?? gameDetailsBloc.state.gameId;
    gameDetailsBloc.add(GetGameDetailsEvent(gameId));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game details'),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.defaultSidePadding,
            right: Dimensions.defaultSidePadding,
            top: Dimensions.sidePadding0_5x,
          ),
          child: BlocBuilder(
            bloc: gameDetailsBloc,
            builder: (context, GameDetailsState state) {
              if (state.status == StateStatus.data) {
                return ListView(
                  children: [
                    _gameResultsPointsTable(state.gameDetails.players),
                    const SizedBox(height: Dimensions.defaultSidePadding),
                    const Text('Player details:'),
                    const SizedBox(height: Dimensions.defaultSidePadding),
                    _playerGameDetailsList(state.gameDetails),
                    const SizedBox(height: Dimensions.defaultSidePadding),
                  ],
                );
              } else if (state.status == StateStatus.error) {
                return Center(
                  child: InfoField(
                    message: state.errorMessage,
                    infoFieldType: InfoFieldType.error,
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )),
    );
  }

  Widget _gameResultsPointsTable(List<PlayerModel> players) {
    return Column(
      children: [
        _tableHeader(),
        _playersTable(players),
      ],
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
              child: const Center(child: Text('BM')),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _scoreColumnFlex,
              child: const Center(child: Text('points')),
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

  Widget _playersTable(List<PlayerModel> players) => Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white30),
            borderRadius: const BorderRadius.all(Radius.circular(0))),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          separatorBuilder: (context, index) => const Divider(
            height: Dimensions.sidePadding0_5x,
          ),
          itemBuilder: (__, index) => _playerItem(
            index,
            players[index],
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
            child: Center(
              child: Text(player.bestMove.toString()),
            ),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _scoreColumnFlex,
            child: Center(
              child: Text(player.gamePoints.toString()),
            ),
          ),
          const VerticalDivider(
            color: Colors.white,
          ),
          Expanded(
            flex: _scoreColumnFlex,
            child: Center(
              child: Text(player.total().toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleIndicator(Role role) {
    return Text(role.name);
  }

  Widget _playerGameDetailsList(GameDetailsModel gameDetails) {
    return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(),
        itemCount: gameDetails.players.length,
        itemBuilder: (context, index) {
          return _playerGameDetailsItem(
              gameDetails.players[index], gameDetails);
        });
  }

  Widget _playerGameDetailsItem(
      PlayerModel player, GameDetailsModel gameDetails) {
    return Padding(
      padding: const EdgeInsets.only(
          right: Dimensions.defaultSidePadding,
          left: Dimensions.defaultSidePadding),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(player.nickname),
                  Text(player.role.name),
                ],
              ),
              const SizedBox(width: Dimensions.defaultSidePadding),
              Text(player.total().toString()),
            ],
          ),
          const Divider(),
          _dayInfoListByPlayer(player, gameDetails),
        ],
      ),
    );
  }

  Widget _dayInfoListByPlayer(
      PlayerModel player, GameDetailsModel gameDetails) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _dayInfoRowItem(
          player,
          gameDetails.dayInfoList[index],
          gameDetails,
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: gameDetails.dayInfoList.length,
    );
  }

  Widget _dayInfoRowItem(
    PlayerModel player,
    DayInfoModel dayInfo,
    GameDetailsModel gameDetails,
  ) {
    final dayGamePhases = gameDetails.gamePhases
        .where((gamePhase) => gamePhase.currentDay == dayInfo.day)
        .sorted(
          (a, b) => a.updatedAt.millisecondsSinceEpoch
              .compareTo(b.updatedAt.millisecondsSinceEpoch),
        );
    final playerActions = GameDetailsViewHelper.filterOnlyPlayerActions(
      player,
      dayGamePhases,
    );
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimensions.playerActionCellSize,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return _phaseItemByPlayerAction(
              player,
              playerActions[index],
            );
          },
          separatorBuilder: (context, index) => const VerticalDivider(),
          itemCount: playerActions.length,
        ));
  }

  Widget _phaseItemByPlayerAction(
    PlayerModel player,
    PlayerActionViewWrapper playerAction,
  ) {
    return Container(
      height: Dimensions.playerActionCellSize,
      width: Dimensions.playerActionCellSize,
      color: Colors.white.withOpacity(0.1),
      child: Text(playerAction.playerAction.name),
    );
  }
}
