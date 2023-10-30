import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';
import 'package:mafia_board/presentation/feature/game_timer_view.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_bloc.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_event.dart';
import 'package:mafia_board/presentation/feature/home/board/board_bloc/board_state.dart';
import 'package:mafia_board/presentation/feature/widgets/info_field.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<StatefulWidget> createState() => _TableState();
}

class _TableState extends State<TablePage> {
  late BoardBloc boardBloc;
  int touchedIndex = -1;

  @override
  void initState() {
    boardBloc = GetIt.I();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.sidePadding0_5x),
      child: BlocBuilder(
        bloc: boardBloc,
        builder: (BuildContext context, BoardState state) {
          return Column(
            children: [
              _header(state),
              const Divider(),
              Stack(
                children: [
                  _table(),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _table() {
    List<PieChartSectionData> sections = [];
    for (var i = 0; i <= 10; i++) {
      if (i == 0) {
        sections.add(PieChartSectionData(
            color: Colors.black,
            badgeWidget: const GameTimerView(),
            value: 20,
            showTitle: false));
      } else {
        sections.add(PieChartSectionData(
          color: Colors.redAccent,
          radius: 90,
          title: i.toString(),
        ));
      }
    }
    double totalValue = sections.fold(
        0, (previousValue, section) => previousValue + section.value);
    double judgeFraction = sections[0].value / totalValue;
    double judgeDegrees = 360 * judgeFraction;
    double startDegreeOffset = 90 - judgeDegrees / 2;
    return AspectRatio(
      aspectRatio: 1.3,
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

  Widget _header(BoardState state) {
    if (state is GamePhaseState && state.gameInfo?.isGameStarted == true) {
      return SizedBox(
          height: Dimensions.headerHeight,
          child: Row(
            children: [
              const GameTimerView(),
              const Spacer(),
              _finishGameButton(),
            ],
          ));
    }
    return SizedBox(
        height: Dimensions.headerHeight,
        child: Center(
          child: _startGameButton(),
        ));
  }

  Widget _finishGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(FinishGameEvent());
      },
      child: const Text(
        'Finish Game',
        style: TextStyle(fontSize: 32),
      ));

  Widget _errorView(String errorMessage) {
    return InfoField(
      message: errorMessage,
      infoFieldType: InfoFieldType.error,
    );
  }

  Widget _startGameButton() => GestureDetector(
      onTap: () {
        boardBloc.add(StartGameEvent());
      },
      child: const Text(
        'Start Game',
        style: TextStyle(fontSize: 32),
      ));
}
