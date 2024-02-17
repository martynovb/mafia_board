import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_status.dart';
import 'package:mafia_board/domain/model/player_model.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_bloc.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_event.dart';
import 'package:mafia_board/presentation/feature/game/game_bloc/game_state.dart';
import 'package:mafia_board/presentation/feature/game/history/game_history_page.dart';
import 'package:mafia_board/presentation/feature/game/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/game/table/table_page.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/widgets/dialogs.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late TabController _pageController;
  late List<Widget> _tabList;
  late GameBloc gameBloc;
  bool _isGameStarted = false;

  @override
  void initState() {
    gameBloc = GetIt.I();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    gameBloc.add(PrepareGameEvent(club: args?['club'] ?? gameBloc.state.club));

    _pageController = TabController(initialIndex: 0, vsync: this, length: 3);
    _tabList = [
      PlayersSheetPage(
          club: args?['club'] ?? gameBloc.state.club,
          onPPKGameFinished: _showFinishConfirmationPPKDialog,
          nextPage: () {
            if (_pageController.index < 2) {
              _pageController.animateTo(_pageController.index + 1);
            }
          }),
      TablePage(onGameFinished: _showFinishConfirmationDialog),
      const GameHistoryPage(),
    ];

    gameBloc.gameStream.listen((gameModel) {
      if (gameModel?.gameStatus == GameStatus.finished &&
          gameModel?.finishGameType == FinishGameType.normalFinish) {
        _showFinishSuccessDialog();
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (invoked) async => _showFinishConfirmationDialog(),
        child: BlocListener(
            bloc: gameBloc,
            listener: (context, GameState state) {
              if (state is GoToGameResults) {
                Navigator.pushNamed(
                  context,
                  AppRouter.gameResultsPage,
                  arguments: {'club': gameBloc.state.club},
                );
              } else if (state is GamePhaseState) {
                _isGameStarted =
                    state.currentGame?.gameStatus == GameStatus.inProgress;
              } else if (state is CloseGameState) {
                Navigator.pop(context);
              }
            },
            child: SafeArea(
              child: Scaffold(
                appBar: _appBar(context),
                body: TabBarView(
                  controller: _pageController,
                  children: _tabList,
                ),
              ),
            )));
  }

  AppBar _appBar(BuildContext context) => AppBar(
        title: const Text('Mafia board'),
        centerTitle: true,
        bottom: TabBar(
          tabs: const [
            Tab(icon: Text('Players')),
            Tab(icon: Text('Table')),
            Tab(icon: Text('History')),
          ],
          controller: _pageController,
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(
                    context,
                    AppRouter.gameRulesPage,
                    arguments: {'clubId': gameBloc.state.club?.id},
                  ),
              icon: const Icon(Icons.settings))
        ],
      );

  Future<bool> _showFinishConfirmationDialog() async {
    if (!_isGameStarted) {
      return true;
    }
    return await showDefaultDialog(
      context: context,
      title: 'Do you want to finish the game?',
      actions: <Widget>[
        TextButton(
          child: const Text("Stop the game and close"),
          onPressed: () {
            gameBloc.add(FinishGameEvent(FinishGameType.reset));
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<bool> _showFinishSuccessDialog() async {
    return await showDefaultDialog(
      context: context,
      title: 'Game has been finished',
      actions: <Widget>[
        TextButton(
          child: const Text('Go to results'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              AppRouter.gameResultsPage,
              arguments: {'club': gameBloc.state.club},
            );
          },
        ),
        TextButton(
          child: const Text('Remove game and exit'),
          onPressed: () {
            gameBloc.add(RemoveGameDataEvent());
            Navigator.of(context).popUntil(
                (route) => route.settings.name == AppRouter.clubDetailsPage);
          },
        ),
      ],
    );
  }

  Future<void> _showFinishConfirmationPPKDialog(PlayerModel player) async {
    await showDefaultDialog(
      context: context,
      title:
          'Do you want to finish the game with PPK for (#${player.seatNumber}: ${player.nickname})?',
      actions: <Widget>[
        TextButton(
          child: const Text("Finish game"),
          onPressed: () {
            gameBloc.add(FinishGameEvent(FinishGameType.ppk, player.tempId));
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
