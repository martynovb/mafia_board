import 'package:easy_localization/easy_localization.dart';
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
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/dialogs.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class GameResultsPage extends StatefulWidget {
  const GameResultsPage({Key? key}) : super(key: key);

  @override
  State<GameResultsPage> createState() => _GameResultsPageState();
}

class _GameResultsPageState extends State<GameResultsPage> {
  late GameResultsBloc gameResultsBloc;

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
    final club = args?['club'] ?? gameResultsBloc.state.club;
    gameResultsBloc.add(CalculateResultsEvent(club));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) => _showExitConfirmationDialog(context),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('gameResults').tr(),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  gameResultsBloc
                      .add(CalculateResultsEvent(gameResultsBloc.state.club));
                },
                icon: const Icon(
                  Icons.refresh,
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(Dimensions.defaultSidePadding),
            child: BlocConsumer(
              bloc: gameResultsBloc,
              listener: (context, GameResultsState state) {
                if (state is GameResultsUploaded) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.homePage,
                    (route) => true,
                  );
                }
              },
              builder: (context, GameResultsState state) {
                if (state is ShowGameResultsState) {
                  return Column(
                    children: [
                      _tableHeader(),
                      _playersTable(state.gameResultsModel),
                    ],
                  );
                } else if (state is GameResultsErrorState) {
                  return Center(
                    child: InfoField(
                      message: state.errorMessage == null
                          ? 'Error during game results calculating'
                          : state.errorMessage!,
                      infoFieldType: InfoFieldType.error,
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ));
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
              child: Center(
                child: const Text('nickname').tr(),
              ),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _roleColumnFlex,
              child: Center(
                child: const Text('role').tr(),
              ),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _scoreColumnFlex,
              child: Center(
                child: const Text('bestMove').tr(),
              ),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _scoreColumnFlex,
              child: Center(
                child: const Text('points').tr(),
              ),
            ),
            const VerticalDivider(
              color: Colors.transparent,
            ),
            Expanded(
              flex: _scoreColumnFlex,
              child: Center(
                child: const Text('total').tr(),
              ),
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
          itemCount: results.allPlayers.length,
          separatorBuilder: (context, index) => const Divider(
            height: Dimensions.sidePadding0_5x,
          ),
          itemBuilder: (__, index) => _playerItem(
            index,
            results.allPlayers[index],
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
    return Text('${roleEmojiMapper(role)} ${role.name.tr()}');
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final currentState = gameResultsBloc.state;
    if (currentState is! ShowGameResultsState) {
      return true;
    }
    return await showDefaultDialog(
      context: context,
      title: 'saveResultsDialogTitle'.tr(),
      actions: <Widget>[
        TextButton(
          child: const Text('no').tr(),
          onPressed: () {
            Navigator.of(context).popUntil(
              (route) => route.settings.name == AppRouter.clubDetailsPage,
            );
          },
        ),
        TextButton(
          child: const Text('yes').tr(),
          onPressed: () {
            Navigator.pop(context);
            gameResultsBloc.add(
              SaveResultsEvent(
                gameResultsModel: currentState.gameResultsModel,
                clubModel: currentState.club,
              ),
            );
          },
        ),
      ],
    );
  }
}
