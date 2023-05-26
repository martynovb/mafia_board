import 'package:flutter/material.dart';
import 'dart:math' as math;

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<StatefulWidget> createState() => _TableState();
}

class _TableState extends State<TablePage> {
  final elevation = 8.0;
  final dividerCount = 11;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('mafia board'),
      ),
      body:  Container(
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
          child: CustomPaint(
            painter: CircleTablePainter(
                tableColor: Colors.red.shade700,
                dividerColor: Colors.black.withOpacity(0.5)),
            child: Container(
              width: MediaQuery.of(context).size.height - 120 - (elevation * 2),
            ),
          ),
        ),
    );
  }
}

class CircleTablePainter extends CustomPainter {
  final Color tableColor;
  final Color dividerColor;
  final Color textColor;
  final int dividerCount;

  CircleTablePainter({
    this.tableColor = Colors.red,
    this.dividerColor = Colors.black,
    this.textColor = Colors.white,
    this.dividerCount = 11,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tablePaint = Paint()
      ..color = tableColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, tablePaint);

    final double angle = 2 * math.pi / dividerCount;

    final dividerPaint = Paint()
      ..color = dividerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    final startingNumber = 1; // Replace with your desired starting number
    final startingAngle = 90; // Replace with your desired starting angle
    final adjustedStartingAngle = startingAngle * (math.pi / 180.0);

    for (int i = 0; i < dividerCount; i++) {
      final adjustedNumber = (i + startingNumber - 1) % dividerCount;
      final currentAngle = adjustedStartingAngle + i * angle;

      _drawDivider(
        canvas: canvas,
        center: center,
        radius: radius,
        dividerPaint: dividerPaint,
        angle: angle,
        number: adjustedNumber,
      );

      _drawNumber(
        canvas: canvas,
        textPainter: textPainter,
        textStyle: textStyle,
        center: center,
        radius: radius,
        angle: angle,
        number: adjustedNumber,
      );
    }
  }

  void _drawDivider({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Paint dividerPaint,
    required double angle,
    required int number,
  }) {
    final start = center;

    final end = Offset(
      center.dx + radius * math.cos(number * angle),
      center.dy + radius * math.sin(number * angle),
    );

    canvas.drawLine(start, end, dividerPaint);
  }

  void _drawNumber({
    required Canvas canvas,
    required TextPainter textPainter,
    required TextStyle textStyle,
    required Offset center,
    required double radius,
    required double angle,
    required int number,
    double offsetFactor = 0.9,
  }) {
    final halfPieceAngle = angle / 2;
    final textAngle = number * angle + halfPieceAngle;

    final textRadius = radius * offsetFactor;
    final textOffset = Offset(
      center.dx + textRadius * math.cos(textAngle),
      center.dy + textRadius * math.sin(textAngle),
    );

    final textSpan = TextSpan(
      text: '${number + 1}',
      style: textStyle,
    );

    textPainter.text = textSpan;
    textPainter.layout();

    final textOffsetCentered = Offset(
      textOffset.dx - textPainter.width / 2,
      textOffset.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffsetCentered);
  }

  @override
  bool shouldRepaint(CircleTablePainter oldDelegate) {
    return oldDelegate.tableColor != tableColor ||
        oldDelegate.dividerColor != dividerColor ||
        oldDelegate.dividerCount != dividerCount;
  }
}
