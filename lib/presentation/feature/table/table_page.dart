import 'package:flutter/material.dart';
import 'package:mafia_board/presentation/feature/table/table_painter.dart';
import 'dart:math' as math;
import 'package:fluttertoast/fluttertoast.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<StatefulWidget> createState() => _TableState();
}

class _TableState extends State<TablePage> {
  late FToast fToast;
  final elevation = 8.0;
  final dividerCount = 11;
  final startAngle = 90;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
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
        child: GestureDetector(
          onTapUp: _onTableTapUp,
          child: CustomPaint(
            painter: TablePainter(
              dividerCount: dividerCount,
              tableColor: Colors.red.shade700,
              dividerColor: Colors.black.withOpacity(0.5),
              judgeCornerColor: Colors.black.withOpacity(0.5),
              startAngle: startAngle,
            ),
            child: Container(
              width: MediaQuery.of(context).size.height - 120 - (elevation * 2),
            ),
          ),
        ),
      ),
    );
  }

  void _onTableTapUp(details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    final double centerX = renderBox.size.width / 2;
    final double centerY = renderBox.size.height / 2;

    final center = Offset(centerX, centerY);
    final radius = renderBox.size.width / 2;

    final double tapX = localPosition.dx;
    final double tapY = localPosition.dy;

    final double distance = calculateDistance(centerX, centerY, tapX, tapY);

    if (distance <= radius) {
      fToast.showToast(
        child: Text('CIRCLE'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(milliseconds: 500),
      );
    }
  }

  double calculateDistance(double x1, double y1, double x2, double y2) {
    final double dx = x2 - x1;
    final double dy = y2 - y1;
    return math.sqrt(dx * dx + dy * dy);
  }
}
