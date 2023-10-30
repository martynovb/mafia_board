import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/home/board/board_page.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_view.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';
import 'package:mafia_board/presentation/feature/router.dart';
import 'package:mafia_board/presentation/feature/table/table_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    double availableHeight = screenHeight - appBarHeight - statusBarHeight;
    double availableWidth = MediaQuery.of(context).size.width - 1; // -1 divider

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.settingsPage),
                    icon: const Icon(Icons.settings))
              ],
            ),
            body: SizedBox(
              height: availableHeight,
              width: availableWidth,
              child: Row(children: [
                SizedBox(
                    width: availableWidth * 0.6,
                    child: Column(
                      children: [
                        SizedBox(
                          height: availableHeight * 0.7,
                          child: const TablePage(),
                        ),
                        const Divider(
                          height: 1,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          height: availableHeight * 0.3 - 1,
                          child: const GameHistoryView(),
                        ),
                      ],
                    )),
                const VerticalDivider(
                  width: 1,
                  color: Colors.white12,
                ),
                SizedBox(
                  width: availableWidth * 0.4 - 1, // -1 divider
                  child: const PlayersSheetPage(),
                ),
              ]),
            )));
  }
}
