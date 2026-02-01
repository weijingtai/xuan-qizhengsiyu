import 'dart:math' as math;

import 'package:flutter/material.dart';

class SectorPainter extends CustomPainter {
  final double startAngle; // 扇环绘制的起始角度（相对于其自身坐标系）
  final double sweepRadian;
  final Color color;
  final double outerRadius;
  final double innerRadius;
  final Color borderColor; // 新增边框颜色参数
  final double borderWidth; // 新增边框宽度参数

  Text? singleText;

  SectorPainter({
    required this.startAngle,
    required this.sweepRadian,
    required this.color,
    required this.outerRadius,
    required this.innerRadius,
    this.borderColor = Colors.black12, // 默认边框颜色
    this.borderWidth = 1.0, // 默认边框宽度
    this.singleText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // 绘制填充扇形
    final Paint fillPaint = Paint()..color = color;
    final Path fillPath = Path()
      ..moveTo(center.dx + innerRadius * math.cos(startAngle),
          center.dy + innerRadius * math.sin(startAngle))
      ..arcTo(outerRect, startAngle, sweepRadian, false)
      ..arcTo(innerRect, startAngle + sweepRadian, -sweepRadian, false)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    // 绘制扇形边框
    if (borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      // 绘制外弧线
      canvas.drawArc(outerRect, startAngle, sweepRadian, false, borderPaint);
      // 绘制内弧线
      canvas.drawArc(innerRect, startAngle, sweepRadian, false, borderPaint);

      // 绘制两条径向边线
      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(startAngle),
            center.dy + innerRadius * math.sin(startAngle)),
        Offset(center.dx + outerRadius * math.cos(startAngle),
            center.dy + outerRadius * math.sin(startAngle)),
        borderPaint,
      );
      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(startAngle + sweepRadian),
            center.dy + innerRadius * math.sin(startAngle + sweepRadian)),
        Offset(center.dx + outerRadius * math.cos(startAngle + sweepRadian),
            center.dy + outerRadius * math.sin(startAngle + sweepRadian)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SectorPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepRadian != sweepRadian ||
        oldDelegate.color != color ||
        oldDelegate.outerRadius != outerRadius ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.borderColor != borderColor || // 检查边框颜色是否变化
        oldDelegate.borderWidth != borderWidth; // 检查边框宽度是否变化
  }
}
