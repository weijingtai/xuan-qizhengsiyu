import 'dart:math';

import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Starinn28ringPainter extends CustomPainter {
  static const int TOTAL = 28;
  final double innerRadius;
  final double outerRadius;
  // tuple5: 东南西北, 星宿名,星宿全称, 颜色, 角度
  // List<Tuple5<int, String, String, Color, num>> twentyEightStarsList;
  List<Tuple3<Enum28Constellations, Color, double>> twentyEightStarsList;
  late TextStyle textStyle;
  bool isReverseText = false;
  bool isReverseOrderSequence = false;

  double innerPadding = 12;
  double outerPadding = 12;

  Starinn28ringPainter({
    required this.innerRadius,
    required this.outerRadius,
    required this.twentyEightStarsList,
    this.isReverseText = true,
    this.isReverseOrderSequence = false,
    this.innerPadding = 12,
    this.outerPadding = 12,
    this.textStyle =
        const TextStyle(color: Colors.black, fontSize: 18, height: 1.2),
  });

  void debugPaint(Canvas canvas, Size size, Offset center) {
    // canvas.translate(center.dx, center.dy);
    // 给canvas绘制灰色透明度为0.1的背景
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 2, backgroundPaint);

    final Paint background2Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, background2Paint);

    final Paint background3Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, background3Paint);
    // 绘制圆心点
    final Paint centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // canvas.save();

    canvas.translate(center.dx, center.dy);
    // canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);

    // final res = sweepAngleDegree *0.5 * math.pi / 180;
    // final double startAngle = math.pi / 2 - res;
    // final double sweepAngle = sweepAngleDegree * math.pi / 180;
    const double startAngle = 0;
    final fanRingWidth = outerRadius - innerRadius;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = fanRingWidth;

    // canvas.translate(center.dx, center.dy);
    // 计算每个扇环的中心角度
    // double angle = startAngle;
    double arcDrawCircleRadius = innerRadius + (fanRingWidth * 0.5);
    // double textRotationAngle =startAngle + sweepAngle / 2;
    // double textRotationAngle =startAngle;

    // 12点方向为起始点
    canvas.rotate(pi - pi / 4);
    // 9点方向为起始点 -- not work
    // canvas.rotate(pi/4);
    // 6点方向为起始点 -- not work
    // canvas.rotate(-pi/4);
    // 3点方向为起始点 -- not work
    // canvas.rotate(pi + pi/4);

    double angleCounter = startAngle;
    for (int i = 0; i < TOTAL; i++) {
      double sweepAngle = -twentyEightStarsList[i].item3 * pi / 180;
      // double sweepAngle = 0.18954444444444445;
      // 绘制扇环
      Path path = Path()
        ..addArc(
          Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius),
          angleCounter,
          sweepAngle,
        );
      // canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), startAngle, sweepAngle, false, paint);
      paint.color = twentyEightStarsList[i].item2;
      canvas.drawPath(path, paint);
      angleCounter += sweepAngle;
    }
    double prevAngle = 0;
    canvas.rotate(pi + pi / 2);

    double radi = pi / 360;
    double offsetRadi = 5 * radi;

    for (int i = 0; i < TOTAL; i++) {
      String text = twentyEightStarsList[i].item1.starName;
      final textSpan = TextSpan(
        text: text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      // angle to radian
      num currentAngle = twentyEightStarsList[i].item3;
      double angle = prevAngle - currentAngle * radi + offsetRadi;
      canvas.rotate(angle);
      prevAngle = -(currentAngle * radi + offsetRadi);
      textPainter.paint(canvas, Offset(0, innerRadius + innerPadding));
    }
  }

  void paintSingleChar(Canvas canvas, Size size, String text, Offset center,
      double rotationAngle, double yOffset) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset offset = isReverseText
        ? Offset(
            -textPainter.width * 0.5,
            -innerRadius -
                innerPadding -
                textPainter.height +
                textPainter.height * .1,
          )
        : Offset(
            -textPainter.width * 0.5,
            innerRadius + innerPadding,
          );
    double rotateAngle = isReverseText ? pi : 0.0;
    canvas.rotate(rotateAngle);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
