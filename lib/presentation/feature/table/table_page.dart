import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<StatefulWidget> createState() => _TableState();
}

class _TableState extends State<TablePage> {
  final elevation = 8.0;
  final dividerCount = 11;
  final startAngle = 90;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('mafia board'),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 16),
        padding: EdgeInsets.all(elevation * 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation,
            ),
          ],
        ),
        child: PlayersSheetPage(),
      ),
    );
  }
}
