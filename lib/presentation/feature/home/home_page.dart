import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/home/board/board_page.dart';
import 'package:mafia_board/presentation/feature/home/history/game_history_view.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('mafia board'),
        ),
        body: Container(
            margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Center(
              child: Row(children: [
                Expanded(
                  flex: 3,
                    child: Column(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: BoardPage(),
                    ),
                    Expanded(
                      flex: 1,
                      child: GameHistoryView(),
                    ),
                  ],
                )),
                const VerticalDivider(
                  color: Colors.white12,
                ),
                const Expanded(
                  flex: 2,
                  child: PlayersSheetPage(),
                ),
              ]),
            )));
  }
}
