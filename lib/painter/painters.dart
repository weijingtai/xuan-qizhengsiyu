import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';

class MyCirclePainter extends CustomPainter {
  double radians;
  double starAngle;
  final String starName;
  final Color backgroundColor;
  final TextStyle textStyle;
  int offsetTimes;
  bool toOuter;
  MyCirclePainter(
      {required this.radians,
      required this.starAngle,
      required this.starName,
      required this.textStyle,
      required this.offsetTimes,
      required this.backgroundColor,
      this.toOuter = false});
  @override
  void paint(Canvas canvas, Size size) {
    // final center = Offset(size.width / 2, size.height / 2);
    // Offset center = toLeft != null?Offset((toLeft!) ?0:size.width, size.height * .5):Offset(size.width * .5, size.height * .5);
    // if (toLeft != null){
    //   offsetTimes = toLeft! ? 1: -1;
    // }else{
    //   offsetTimes = 0;
    // }
    // Offset center = Offset(size.width*.5-(offsetTimes*size.width*.5),size.height*.5);
    // print("$starName - $starAngle");
    double centerX = size.width * .5 - (offsetTimes * size.width * .5);
    int subCenterHeightTimes = 0;
    if (offsetTimes != 0) {
      subCenterHeightTimes = offsetTimes < 0 ? offsetTimes * -1 : offsetTimes;
    }
    double centerY =
        size.height * .5 + (size.height * .05 * subCenterHeightTimes);
    if (subCenterHeightTimes >= 7) {
      centerY += size.height * .2;
    }
    if (subCenterHeightTimes >= 9) {
      centerY += size.height * .3;
    }
    Offset center = Offset(centerX, centerY);
    // print("$center $subCenterHeightTimes ${size.width*.5}");
    const radius = 16.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    // line's shadow
    if (toOuter) {
      canvas.drawLine(
          center,
          Offset(size.width * .5, -size.height * .2),
          Paint()
            ..color = textStyle.color!
            ..strokeWidth = .5);
      canvas.drawLine(
          center,
          Offset(size.width * .5, -size.height * .2),
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
    } else {
      canvas.drawLine(
          center,
          Offset(size.width * .5, size.height),
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
      canvas.drawLine(
          center,
          Offset(size.width * .5, size.height),
          Paint()
            ..color = textStyle.color!
            ..strokeWidth = .5);
    }

    // add shadow to drawLine

    canvas.translate(center.dx, center.dy);

    // canvas.drawLine(center, Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), Paint()..color = Colors.red);

    // turning with 45 degree, turning center is center
    // canvas.translate(0, size.height / 2);
    // canvas.translate(size.width, size.height / 2);

    // canvas.rotate(pi / 6);
    // canvas.rotate((360-108) * pi / 180);

    canvas.drawCircle(Offset.zero, radius * .3,
        Paint()..color = textStyle.color!.withOpacity(.3));
    canvas.drawCircle(const Offset(1, 1), radius * .3,
        Paint()..color = textStyle.color!.withOpacity(.1));

    // canvas draw image from assets
    // ui.Image.asset("assets/planets/mars-bubbles-50.png")

    // draw a background block size as this canvas, color with Colors.black.whithOpactiy(.1)
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.4));

    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height), Paint()..color = Colors.black87.withOpacity(.5));

    canvas.rotate(radians);
    // draw text content

    var textPainter = TextPainter(
      text: TextSpan(
        text: starName,
        style: textStyle,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2 + 1));

    var typeTextPainter = TextPainter(
      text: TextSpan(
        text: "荫",
        style: textStyle.copyWith(color: Colors.black45, fontSize: 12),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    typeTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    if (toOuter) {
      if (starAngle < 180) {
        typeTextPainter.paint(
            canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      } else {
        typeTextPainter.paint(canvas,
            Offset(textPainter.width * .5, -textPainter.height / 2 - 1));
      }
    } else {
      if (starAngle < 180) {
        typeTextPainter.paint(canvas,
            Offset(textPainter.width * .5, -textPainter.height / 2 - 1));
      } else {
        typeTextPainter.paint(
            canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      }
    }

    if (["金", "木", "水", "火", "土"].contains(starName)) {
      var typeTextPainter = TextPainter(
        text: TextSpan(
          text: "速",
          style: textStyle.copyWith(color: Colors.red, fontSize: 12),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      typeTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      if (toOuter) {
        if (starAngle < 180) {
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        } else {
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        }
      } else {
        if (starAngle < 180) {
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        } else {
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        }
      }
    }
    // draw a red dot at center
    // canvas.drawCircle(Offset.zero, 1, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant MyCirclePainter oldDelegate) {
    return radians != oldDelegate.radians ||
        starAngle != oldDelegate.starAngle ||
        starName != oldDelegate.starName ||
        offsetTimes != oldDelegate.offsetTimes ||
        toOuter != oldDelegate.toOuter ||
        textStyle != oldDelegate.textStyle ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class IndicatorScalePainter extends CustomPainter {
  final double ringWidth;
  final double tickLength;
  final double indicatorAngle;

  IndicatorScalePainter({
    required this.indicatorAngle,
    required this.ringWidth,
    required this.tickLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius - ringWidth;
    // final Paint ringPaint = Paint()
    //   ..color = Colors.black
    //   ..strokeWidth = .5
    //   ..style = PaintingStyle.stroke;

    // Draw outer ring
    // canvas.drawCircle(Offset(centerX, centerY), outerRadius, ringPaint);

    // Draw inner ring
    // canvas.drawCircle(Offset(centerX, centerY), innerRadius, ringPaint);

    final Paint scalePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw regular tick marks
    final double angle = indicatorAngle * pi / 180;
    double length = tickLength;
    // if (i != 0){
    //   if (i % 10 == 0){
    //     length = tickLength *2;
    //   }else if (i % 5 == 0){
    //     length = tickLength + tickLength *0.5;
    //   }
    // }
    final double outerX = centerX + outerRadius * cos(angle);
    final double outerY = centerY + outerRadius * sin(angle);
    final double innerX = centerX + (outerRadius - length) * cos(angle);
    final double innerY = centerY + (outerRadius - length) * sin(angle);
    // Draw scale line near the outer ring
    canvas.drawLine(
      Offset(outerX, outerY),
      Offset(innerX, innerY),
      scalePaint,
    );

    final double innerTickStartX = centerX + innerRadius * cos(angle);
    final double innerTickStartY = centerY + innerRadius * sin(angle);
    final double innerTickEndX = centerX + (innerRadius + length) * cos(angle);
    final double innerTickEndY = centerY + (innerRadius + length) * sin(angle);

    // Draw scale line near the inner ring
    canvas.drawLine(
      Offset(innerTickStartX, innerTickStartY),
      Offset(innerTickEndX, innerTickEndY),
      scalePaint,
    );
  }

  @override
  bool shouldRepaint(covariant IndicatorScalePainter oldDelegate) {
    return indicatorAngle != oldDelegate.indicatorAngle ||
        ringWidth != oldDelegate.ringWidth ||
        tickLength != oldDelegate.tickLength;
  }
}

class StarBodyPainter extends CustomPainter {
  UIStarModel star;
  // ElevenStarsInfo starInfo;
  double radians;
  double get starAngle => star.angle;
  double get uiStarAngle => star.originalAngle;
  String get starName => star.star.singleName;

  final Color backgroundColor;
  final TextStyle textStyle;
  bool toOuter;
  StarBodyPainter(
      {required this.star,
      // required this.starInfo,
      required this.radians,
      required this.textStyle,
      required this.backgroundColor,
      this.toOuter = false});
  @override
  void paint(Canvas canvas, Size size) {
    // final center = Offset(size.width / 2, size.height / 2);
    // Offset center = toLeft != null?Offset((toLeft!) ?0:size.width, size.height * .5):Offset(size.width * .5, size.height * .5);
    // if (toLeft != null){
    //   offsetTimes = toLeft! ? 1: -1;
    // }else{
    //   offsetTimes = 0;
    // }
    // Offset center = Offset(size.width*.5-(offsetTimes*size.width*.5),size.height*.5);

    int offsetTimes = 0;
    int subCenterHeightTimes = 0;
    // print("$starName - $starAngle");
    double centerX = size.width * .5 - (offsetTimes * size.width * .5);

    double centerY =
        size.height * .5 + (size.height * .05 * subCenterHeightTimes);
    if (subCenterHeightTimes >= 7) {
      centerY += size.height * .2;
    }
    if (subCenterHeightTimes >= 9) {
      centerY += size.height * .3;
    }
    Offset center = Offset(centerX, centerY);
    // print("$center $subCenterHeightTimes ${size.width*.5}");
    const radius = 16.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    // line's shadow
    if (toOuter) {
      canvas.drawLine(
          center,
          Offset(size.width * .5, -size.height * .2),
          Paint()
            // ..color = textStyle.color!
            ..color = Colors.red
            ..strokeWidth = .5);
      canvas.drawLine(
          center,
          Offset(size.width * .5, -size.height * .2),
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
    } else {
      canvas.drawLine(
          center,
          Offset(size.width * .5, size.height),
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
      canvas.drawLine(
          center,
          Offset(size.width * .5, size.height),
          Paint()
            // ..color = textStyle.color!
            // ..strokeWidth = .5
            ..color = Colors.red
            ..strokeWidth = .5);
    }

    // add shadow to drawLine

    canvas.translate(center.dx, center.dy);

    // canvas.drawLine(center, Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), Paint()..color = Colors.red);

    // turning with 45 degree, turning center is center
    // canvas.translate(0, size.height / 2);
    // canvas.translate(size.width, size.height / 2);

    // canvas.rotate(pi / 6);
    // canvas.rotate((360-108) * pi / 180);

    canvas.drawCircle(Offset.zero, radius * .3,
        Paint()..color = textStyle.color!.withOpacity(.3));
    canvas.drawCircle(const Offset(1, 1), radius * .3,
        Paint()..color = textStyle.color!.withOpacity(.1));

    // canvas draw image from assets
    // ui.Image.asset("assets/planets/mars-bubbles-50.png")

    // draw a background block size as this canvas, color with Colors.black.whithOpactiy(.1)
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.4));

    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height), Paint()..color = Colors.black87.withOpacity(.5));

    canvas.rotate(radians);
    // draw text content

    var textPainter = TextPainter(
      text: TextSpan(
        text: starName,
        style: textStyle,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2 + 1));

    var typeTextPainter = TextPainter(
      text: TextSpan(
        text: "荫",
        style: textStyle.copyWith(color: Colors.black45, fontSize: 12),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    typeTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    if (toOuter) {
      if (starAngle < 180) {
        typeTextPainter.paint(
            canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      } else {
        typeTextPainter.paint(canvas,
            Offset(textPainter.width * .5, -textPainter.height / 2 - 1));
      }
    } else {
      if (starAngle < 180) {
        typeTextPainter.paint(canvas,
            Offset(textPainter.width * .5, -textPainter.height / 2 - 1));
      } else {
        typeTextPainter.paint(
            canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      }
    }

    if (["金", "木", "水", "火", "土"].contains(starName)) {
      var typeTextPainter = TextPainter(
        text: TextSpan(
          text: "速",
          style: textStyle.copyWith(color: Colors.red, fontSize: 12),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      typeTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      if (toOuter) {
        if (starAngle < 180) {
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        } else {
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        }
      } else {
        if (starAngle < 180) {
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        } else {
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        }
      }
    }

    // draw a red dot at center
    // canvas.drawCircle(Offset.zero, 1, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant StarBodyPainter oldDelegate) {
    return star != oldDelegate.star ||
        radians != oldDelegate.radians ||
        toOuter != oldDelegate.toOuter ||
        textStyle != oldDelegate.textStyle ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
