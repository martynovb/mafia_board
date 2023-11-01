import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mafia_board/data/model/player_model.dart';
import 'package:mafia_board/data/model/role.dart';
import 'package:mafia_board/presentation/feature/dimensions.dart';

class TableWidget extends StatefulWidget {
  final Widget center;
  Widget? judgeSide = Container();
  final List<PlayerModel> players;
  final Function(PlayerModel player) onPlayerClicked;
  Function(PlayerModel player)? onPlayerLongPress = (_) {};
  final List<HighlightedPlayerData> highlightedPlayerList;

  TableWidget({
    super.key,
    required this.players,
    required this.onPlayerClicked,
    this.onPlayerLongPress,
    this.highlightedPlayerList = const [],
    required this.center,
    this.judgeSide,
  });

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: Dimensions.tableHeight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _table(),
              widget.center,
            ],
          ));
    });
  }

  Widget _table() {
    List<PieChartSectionData> sections = [];
    if(widget.players.isEmpty){
      return Container();
    }
    for (var i = 0; i <= widget.players.length; i++) {
      if (i == 0) {
        sections.add(PieChartSectionData(
            color: Colors.black,
            value: 20,
            radius: 70,
            showTitle: false,
            badgeWidget: widget.judgeSide));
      } else {
        final player = widget.players[i - 1];
        final highlightedPlayer = widget.highlightedPlayerList
            .firstWhereOrNull((hgData) => hgData.player.id == player.id);
        sections.add(PieChartSectionData(
          badgeWidget: _playerSectorBadgeMapper(player, highlightedPlayer),
          badgePositionPercentageOffset: 0.8,
          color: _playerSectorColorMapper(player, highlightedPlayer),
          borderSide: _playerSectorBorderMapper(player, highlightedPlayer),
          radius: _playerSectorRadiusMapper(i, player, highlightedPlayer),
          titleStyle: const TextStyle(fontWeight: FontWeight.bold),
          title: player.seatNumber.toString(),
        ));
      }
    }
    double totalValue = sections.fold(
        0, (previousValue, section) => previousValue + section.value);
    double judgeFraction = sections[0].value / totalValue;
    double judgeDegrees = 360 * judgeFraction;
    double startDegreeOffset = 90 - judgeDegrees / 2;
    return PieChart(
      PieChartData(
        startDegreeOffset: startDegreeOffset,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            final touchedSection = pieTouchResponse?.touchedSection;
            if (touchedSection == null ||
                !event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                event is FlTapUpEvent ||
                event is FlPanCancelEvent) {
              setState(() {
                touchedIndex = -1;
              });
            } else if (event is FlPanDownEvent) {
              widget.onPlayerClicked(
                widget.players[touchedSection.touchedSectionIndex - 1],
              );
              setState(() {
                touchedIndex = touchedSection.touchedSectionIndex;
              });
            } else if (event is FlLongPressStart &&
                widget.onPlayerLongPress != null) {
              widget.onPlayerLongPress!(
                  widget.players[touchedSection.touchedSectionIndex - 1]);
            }
          },
        ),
        centerSpaceColor: Colors.black12,
        sectionsSpace: 1,
        sections: sections,
      ),
    );
  }

  Widget _playerSectorBadgeMapper(
    PlayerModel playerModel,
    HighlightedPlayerData? highlightedPlayerData,
  ) {
    if (highlightedPlayerData != null && highlightedPlayerData.isVoted) {
      return const Icon(Icons.thumb_up);
    } else if (highlightedPlayerData != null &&
        highlightedPlayerData.selectedToKill) {
      return const Icon(
        Icons.close,
        color: Colors.white,
      );
    } else if (highlightedPlayerData != null &&
        highlightedPlayerData.showRole) {
      return Icon(
        _mapIconByRole(highlightedPlayerData.player.role),
      );
    }
    return Container();
  }

  Color _playerSectorColorMapper(
    PlayerModel playerModel,
    HighlightedPlayerData? highlightedPlayerData,
  ) {
    if (playerModel.isKicked || playerModel.isRemoved) {
      return Colors.white12;
    } else if (highlightedPlayerData != null &&
        (highlightedPlayerData.selectedToKill)) {
      return Colors.black;
    } else if (highlightedPlayerData != null &&
        (highlightedPlayerData.showRole)) {
      return _mapBackgroundColorByRole(highlightedPlayerData.player.role!);
    } else if (highlightedPlayerData != null &&
        (highlightedPlayerData.isVoted)) {
      return Colors.grey;
    } else if (highlightedPlayerData != null &&
        (highlightedPlayerData.isSpeaking || highlightedPlayerData.onVote)) {
      return Colors.redAccent.shade100;
    }
    return Colors.redAccent;
  }

  BorderSide _playerSectorBorderMapper(
    PlayerModel playerModel,
    HighlightedPlayerData? highlightedPlayerData,
  ) {
    if (highlightedPlayerData != null &&
        (highlightedPlayerData.isReadyToSpeak ||
            highlightedPlayerData.isSpeaking ||
            highlightedPlayerData.onVote)) {
      return const BorderSide(color: Colors.white, width: 3);
    }
    return const BorderSide(color: Colors.transparent, width: 0);
  }

  double _playerSectorRadiusMapper(
    int index,
    PlayerModel playerModel,
    HighlightedPlayerData? highlightedPlayerData,
  ) {
    if (index == touchedIndex) {
      return 85;
    }
    return 90;
  }

  IconData _mapIconByRole(Role? role) {
    if (role == Role.DON || role == Role.MAFIA) {
      return Icons.thumb_down;
    } else if (role == Role.CIVILIAN) {
      return Icons.thumb_up;
    } else if (role == Role.SHERIFF) {
      return Icons.local_police_outlined;
    }

    return Icons.question_mark;
  }

  Color _mapBackgroundColorByRole(Role role) {
    if (role == Role.DON || role == Role.MAFIA) {
      return Colors.black;
    } else if (role == Role.CIVILIAN) {
      return Colors.red.shade300;
    } else if (role == Role.SHERIFF) {
      return Colors.green.withOpacity(0.3);
    }

    return Colors.redAccent;
  }
}

class HighlightedPlayerData {
  final PlayerModel player;
  final bool isSpeaking;
  final bool isReadyToSpeak;
  final bool showRole;
  final bool selectedToKill;
  final bool onVote;
  final bool isVoted;

  HighlightedPlayerData({
    required this.player,
    this.isSpeaking = false,
    this.showRole = false,
    this.selectedToKill = false,
    this.onVote = false,
    this.isVoted = false,
    this.isReadyToSpeak = false,
  });
}
