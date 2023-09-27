import 'package:flutter/material.dart';
import 'dart:math' as math;

class TablePainter extends CustomPainter {
  final Color tableColor;
  final Color dividerColor;
  final Color textColor;
  final Color judgeCornerColor;
  final int dividerCount;
  final int startAngle;

  TablePainter({
    this.tableColor = Colors.red,
    this.dividerColor = Colors.black,
    this.textColor = Colors.white,
    this.judgeCornerColor = Colors.black,
    this.dividerCount = 11,
    this.startAngle = 90,
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

    final startingAngle = startAngle + (360 / dividerCount / 2);
    final adjustedStartingAngle = startingAngle * (math.pi / 180.0);

    for (int i = 0; i < dividerCount; i++) {
      final currentAngle = adjustedStartingAngle + i * angle;

      final startAngle = currentAngle;
      final endAngle = currentAngle + angle;

      _drawDivider(
        canvas: canvas,
        center: center,
        radius: radius,
        dividerPaint: dividerPaint,
        angle: angle,
        number: i,
        startAngle: currentAngle,
        endAngle: endAngle,
      );

      _drawNumber(
        canvas: canvas,
        textPainter: textPainter,
        textStyle: textStyle,
        center: center,
        radius: radius,
        angle: angle,
        number: i,
        startAngle: startAngle,
        endAngle: endAngle,
      );
    }

    _changePieceColorBackground(
        canvas: canvas,
        index: 10,
        adjustedStartingAngle: adjustedStartingAngle,
        angle: angle,
        center: center,
        radius: radius);
  }

  void _drawDivider({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Paint dividerPaint,
    required double angle,
    required int number,
    required double startAngle,
    required double endAngle,
  }) {
    final start = center;

    final end = Offset(
      center.dx + radius * math.cos(endAngle + (number + 1) * angle),
      center.dy + radius * math.sin(endAngle + (number + 1) * angle),
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
    required double startAngle,
    required double endAngle,
    double offsetFactor = 0.9,
  }) {
    if (number == dividerCount - 1) {
      return;
    }

    final textAngle = (startAngle + endAngle) / 2;

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

  void _changePieceColorBackground({
    required Canvas canvas,
    required int index,
    required double adjustedStartingAngle,
    required double angle,
    required Offset center,
    required double radius,
  }) {
    final startAngle = adjustedStartingAngle + index * angle;

    final backgroundPaint = Paint()
      ..color = judgeCornerColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, startAngle, angle, true, backgroundPaint);
  }

  @override
  bool shouldRepaint(TablePainter oldDelegate) {
    return oldDelegate.tableColor != tableColor ||
        oldDelegate.dividerColor != dividerColor ||
        oldDelegate.dividerCount != dividerCount;
  }

  /*
  *   void _onTableTapUp(details) {
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
  * */
}