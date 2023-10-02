import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/home/board/board_page.dart';
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
            margin: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Center(
              child: Row(children: const [
                Expanded(
                  flex: 2,
                  child: BoardPage(),
                ),
                VerticalDivider(
                  color: Colors.white12,
                ),
                Expanded(
                  flex: 1,
                  child: PlayersSheetPage(),
                ),
              ]),
            )));
  }
}
