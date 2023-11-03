import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_page.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/table/table_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late TabController _pageController;

  late List<Widget> _tabList;

  @override
  void initState() {
    _pageController = TabController(initialIndex: 0, vsync: this, length: 3);
    _tabList = [
      PlayersSheetPage(nextPage: () {
        if (_pageController.index < 2) {
          _pageController.animateTo(_pageController.index + 1);
        }
      }),
      const TablePage(),
      const GameHistoryPage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:  Scaffold(
        appBar: _appBar(context),
        body: TabBarView(
          controller: _pageController,
          children: _tabList,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
        title: Text('Mafia board'),
        centerTitle: true,
        bottom: TabBar(
          tabs: [
            Tab(icon: Text('Players')),
            Tab(icon: Text('Table')),
            Tab(icon: Text('History')),
          ],
          controller: _pageController,
        ),
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.settingsPage),
              icon: const Icon(Icons.settings))
        ],
      );
}
