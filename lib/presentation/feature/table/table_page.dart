import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/home/players_sheet/players_sheet_page.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<StatefulWidget> createState() => _TableState();
}

class _TableState extends State<TablePage> {
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      _table(),
    ]);
  }

  Widget _table() {
    List<PieChartSectionData> sections = [];
    for (var i = 0; i <= 10; i++) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      if (i == 0) {
        sections.add(PieChartSectionData(color: Colors.black, badgeWidget: GameTimerView(), value: 20, showTitle: false));
      } else {
        sections.add(PieChartSectionData(
          color: Colors.redAccent,
          radius: 90,
          title: i.toString(),
        ));
      }
    }

// Calculate total value of all sections
    double totalValue = sections.fold(
        0, (previousValue, section) => previousValue + section.value);

// Calculate the fraction occupied by the judge section
    double judgeFraction = sections[0].value / totalValue;

// Calculate the degrees occupied by the judge section
    double judgeDegrees = 360 * judgeFraction;

// Adjust startDegreeOffset to center judge section at 270 degrees
    double startDegreeOffset = 90 - judgeDegrees / 2;
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          startDegreeOffset: startDegreeOffset,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          centerSpaceColor: Colors.black12,
          sectionsSpace: 1,
          sections: sections,
        ),
      ),
    );
  }

  void _handleKickAction(int index) {
    print('Player ${index + 1} clicked');
    // Implement further actions, e.g., removing the player, showing a dialog, etc.
  }
}
