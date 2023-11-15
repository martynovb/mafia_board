import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/domain/model/finish_game_type.dart';
import 'package:mafia_board/domain/model/game_status.dart';
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
  late String clubId;
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
    clubId = args?['clubId'] ?? '';

    _pageController = TabController(initialIndex: 0, vsync: this, length: 3);
    _tabList = [
      PlayersSheetPage(
          clubId: clubId,
          nextPage: () {
            if (_pageController.index < 2) {
              _pageController.animateTo(_pageController.index + 1);
            }
          }),
      TablePage(onGameFinished: _showFinishConfirmationDialog),
      const GameHistoryPage(),
    ];

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => _showFinishConfirmationDialog(),
        child: BlocListener(
            bloc: gameBloc,
            listener: (context, GameState state) {
              if (state is GoToGameResults) {
                Navigator.pushNamed(context, AppRouter.gameResultsPage);
              } else if (state is GamePhaseState) {
                _isGameStarted = state.currentGame?.gameStatus == GameStatus.inProgress;
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
                    arguments: {'clubId': clubId},
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
          child: const Text('PPK - Civilians won'),
          onPressed: () {
            gameBloc.add(FinishGameEvent(FinishGameType.ppkCiv));
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('PPK - Mafia won'),
          onPressed: () {
            gameBloc.add(FinishGameEvent(FinishGameType.ppkMaf));
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Just finish and don't save results"),
          onPressed: () {
            gameBloc.add(FinishGameEvent(FinishGameType.remove));
            Navigator.of(context).pop(true);
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
