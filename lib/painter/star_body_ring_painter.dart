import 'dart:math';

import 'package:common/enums.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';

class OuterLifeStarRangePainter extends CustomPainter {
  double innerSize;
  double trackSize;
  double outerSize;
  double get innerRadius => innerSize * .5;
  double get trackRadius => trackSize * .5;
  double get outerRadius => outerSize * .5;

  List<UIStarModel> stars;
  final TextStyle textStyle;
  Map<EnumStars, Color> starsColorMap;
  bool showStarTrackLine;
  bool showText;

  // ElevenStarsInfo starInfo;
  OuterLifeStarRangePainter({
    required this.stars,
    required this.textStyle,
    required this.starsColorMap,
    required this.innerSize,
    required this.trackSize,
    required this.outerSize,
    this.showText = false,
    this.showStarTrackLine = false,
  });
// 定义一个函数来计算圆上某一角度对应的点的坐标
  Offset calculatePointOnCircle(double radius, double angle) {
    // 将角度转换为弧度，因为三角函数接受的参数是弧度制
    double radians = angle * (pi / 180);
    // 根据公式计算 x 坐标，由于圆心 x 坐标为 0，可简化为 x = radius * cos(radians)
    double x = radius * cos(radians);
    // 根据公式计算 y 坐标，由于圆心 y 坐标为 0，可简化为 y = radius * sin(radians)
    double y = radius * sin(radians);
    return Offset(x, y);
  }

  Offset calculateCoordinates(
      double centerX, double centerY, double radius, double angle) {
    // 将角度转换为弧度，因为 Dart 中的三角函数接受的参数是弧度制
    double radians = angle * (pi / 180);
    // 根据公式计算 x 坐标
    double x = centerX + radius * cos(radians);
    // 根据公式计算 y 坐标
    double y = centerY + radius * sin(radians);
    // 返回包含 x 和 y 坐标的列表
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 绘制一条0刻度其实线
    // final zeroLinePaint = Paint()
    //   ..color = Colors.red
    //   ..style = PaintingStyle.stroke
    // ..strokeWidth = 1;
    // canvas.drawLine(Offset(center.dx, center.dy), Offset(center.dx*2, center.dy), zeroLinePaint);
    if (showStarTrackLine) {
      final paintStarsTrack = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5;
      canvas.drawCircle(center, trackRadius, paintStarsTrack);
    }

    canvas.translate(center.dx, center.dy);
    canvas.save();

    for (int i = 0; i < stars.length; i++) {
      // paint guid line side dot at ring inner border
      UIStarModel star = stars[i];
      Color color = starsColorMap[star.star]!;

      Offset inRingXY =
          calculatePointOnCircle(innerRadius, -star.originalAngle);
      Offset outRingXY = calculatePointOnCircle(trackRadius, -star.angle);

      final zeroLinePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(inRingXY, outRingXY, zeroLinePaint);
      final guidDot = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;
      canvas.drawCircle(inRingXY, 2, guidDot);

      final starHolderDot = Paint()
        ..color = color.withOpacity(.4)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;
      canvas.drawCircle(outRingXY, 6, starHolderDot);
    }
    canvas.restore();
    if (showText) {
      // paint each star
      for (int i = 0; i < stars.length; i++) {
        canvas.save();
        UIStarModel star = stars[i];
        if (i == 0) {
          // print(star.angle);
        }

        canvas.rotate(-star.angle * (pi / 180));
        canvas.translate(trackRadius, 0);
        canvas.rotate((360 - 30 + star.angle) * (pi / 180));
        paintEachStar(canvas, star);
        canvas.restore();
      }
    }
  }

  void paintEachStar(Canvas canvas, UIStarModel star) {
    // debugPrint("paint star ${star.star.singleName}");
    double textSize = 16;
    var textPainter = TextPainter(
      text: TextSpan(
        text: star.star.singleName,
        style: textStyle.copyWith(color: starsColorMap[star.star]!),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: textSize,
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
      maxWidth: textSize,
    );
    if (star.angle < 180) {
      typeTextPainter.paint(
          canvas, Offset(textPainter.width * .5, -textPainter.height / 2 - 1));
    } else {
      typeTextPainter.paint(
          canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
    }

    if (["金", "木", "水", "火", "土"].contains(star.star.singleName)) {
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
        maxWidth: textSize,
      );
      if (star.angle < 180) {
        typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
      } else {
        typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
      }
    }
  }

  @override
  bool shouldRepaint(covariant OuterLifeStarRangePainter oldDelegate) {
    return innerSize != oldDelegate.innerSize ||
        trackSize != oldDelegate.trackSize ||
        outerSize != oldDelegate.outerSize ||
        showStarTrackLine != oldDelegate.showStarTrackLine ||
        showText != oldDelegate.showText ||
        textStyle != oldDelegate.textStyle ||
        !listEquals(stars, oldDelegate.stars) ||
        !mapEquals(starsColorMap, oldDelegate.starsColorMap);
  }
}

class InnerLifeStarRangePainter extends CustomPainter {
  double innerSize;
  double trackSize;
  double outerSize;

  double get innerRadius => innerSize * .5;
  double get trackRadius => trackSize * .5;
  double get outerRadius => outerSize * .5;
  List<UIStarModel> stars;
  final TextStyle textStyle;
  Map<EnumStars, Color> starsColorMap;
  // bool toOuter;
  bool showStarTrackLine;
  bool showText;

  // ElevenStarsInfo starInfo;
  // double radians;
  // double get starAngle => star.angle;
  // double get uiStarAngle => star.originalAngle;
  // String get starName=>star.star.singleName;

  double innerPadding;

  InnerLifeStarRangePainter(
      {required this.stars,
      required this.textStyle,
      required this.starsColorMap,
      required this.innerSize,
      required this.trackSize,
      required this.outerSize,
      this.showStarTrackLine = false,
      this.showText = false,
      this.innerPadding = 16.0});
// 定义一个函数来计算圆上某一角度对应的点的坐标
  Offset calculatePointOnCircle(double radius, double angle) {
    // 将角度转换为弧度，因为三角函数接受的参数是弧度制
    double radians = angle * (pi / 180);
    // 根据公式计算 x 坐标，由于圆心 x 坐标为 0，可简化为 x = radius * cos(radians)
    double x = radius * cos(radians);
    // 根据公式计算 y 坐标，由于圆心 y 坐标为 0，可简化为 y = radius * sin(radians)
    double y = radius * sin(radians);
    return Offset(x, y);
  }

  Offset calculateCoordinates(
      double centerX, double centerY, double radius, double angle) {
    // 将角度转换为弧度，因为 Dart 中的三角函数接受的参数是弧度制
    double radians = angle * (pi / 180);
    // 根据公式计算 x 坐标
    double x = centerX + radius * cos(radians);
    // 根据公式计算 y 坐标
    double y = centerY + radius * sin(radians);
    // 返回包含 x 和 y 坐标的列表
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // // 绘制一条0刻度其实线
    // final zeroLinePaint = Paint()
    //   ..color = Colors.red
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1;
    // canvas.drawLine(Offset(center.dx, center.dy), Offset(center.dx*2, center.dy), zeroLinePaint);
    //
    // paint center dot
    // final centerDot = Paint()
    //   ..color = Colors.red
    //   ..style = PaintingStyle.fill
    //   ..strokeWidth = 2.0;
    // canvas.drawCircle(center, 5, centerDot);
    //
    // 绘制星体轨道

    // final radius = size.width * .5 - innerPadding * 1.8;
    // final radius = trackSize;
    if (showStarTrackLine) {
      final paintStarsTrack = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5;
      canvas.drawCircle(center, trackRadius, paintStarsTrack);
    }
    canvas.translate(center.dx, center.dy);
    canvas.save();

    // canvas.translate(radius,0);
    // canvas.rotate((360-30) * (pi/180));
    // paintEachStar(canvas,UIStarModel(
    //     star: EnumStars.Sun,
    //     priority: 4,
    //     originalAngle: 0,
    //     rangeAngleEachSide: 4));
    // canvas.restore();

    // canvas.rotate(-(360-30) * (pi/180));
    for (int i = 0; i < stars.length; i++) {
      // paint guid line side dot at ring inner border
      UIStarModel star = stars[i];
      Color color = starsColorMap[star.star]!;

      Offset inRingXY =
          calculatePointOnCircle(outerRadius, -star.originalAngle);
      Offset outRingXY = calculatePointOnCircle(trackRadius, -star.angle);

      final zeroLinePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(inRingXY, outRingXY, zeroLinePaint);
      final guidDot = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;
      canvas.drawCircle(inRingXY, 2, guidDot);

      final starHolderDot = Paint()
        ..color = color.withOpacity(.4)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;
      canvas.drawCircle(outRingXY, 6, starHolderDot);
    }
    canvas.restore();

    // paint each star
    if (showText) {
      for (int i = 0; i < stars.length; i++) {
        canvas.save();
        UIStarModel star = stars[i];
        canvas.rotate(-star.angle * (pi / 180));
        canvas.translate(trackRadius, 0);
        canvas.rotate((360 - 30 + star.angle) * (pi / 180));
        paintEachStar(canvas, star);
        canvas.restore();
      }
    }
  }

  void paintEachStar(Canvas canvas, UIStarModel star) {
    double textSize = 16;
    var textPainter = TextPainter(
      text: TextSpan(
        text: star.star.singleName,
        style: textStyle.copyWith(color: starsColorMap[star.star]!),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: textSize,
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
      maxWidth: textSize,
    );
    if (star.angle < 180) {
      typeTextPainter.paint(
          canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
    } else {
      typeTextPainter.paint(
          canvas, Offset(textPainter.width * .5, -textPainter.height / 2 - 1));
    }

    if (["金", "木", "水", "火", "土"].contains(star.star.singleName)) {
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
        maxWidth: textSize,
      );
      if (star.angle < 180) {
        typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
      } else {
        typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
      }
    }
  }

  @override
  bool shouldRepaint(covariant InnerLifeStarRangePainter oldDelegate) {
    return innerSize != oldDelegate.innerSize ||
        trackSize != oldDelegate.trackSize ||
        outerSize != oldDelegate.outerSize ||
        innerPadding != oldDelegate.innerPadding ||
        showStarTrackLine != oldDelegate.showStarTrackLine ||
        showText != oldDelegate.showText ||
        textStyle != oldDelegate.textStyle ||
        !listEquals(stars, oldDelegate.stars) ||
        !mapEquals(starsColorMap, oldDelegate.starsColorMap);
  }
}

class RingSheetPainter extends CustomPainter {
  double innerRadius;
  double outerRadius;

  RingSheetPainter({
    required this.innerRadius,
    required this.outerRadius,
  });

// 定义一个函数来计算圆上某一角度对应的点的坐标
  Offset calculatePointOnCircle(double radius, double angle) {
    // 将角度转换为弧度，因为三角函数接受的参数是弧度制
    double radians = angle * (pi / 180);
    // 根据公式计算 x 坐标，由于圆心 x 坐标为 0，可简化为 x = radius * cos(radians)
    double x = radius * cos(radians);
    // 根据公式计算 y 坐标，由于圆心 y 坐标为 0，可简化为 y = radius * sin(radians)
    double y = radius * sin(radians);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.save();
    for (int i = 0; i < 12; i++) {
      final double angle = i * 30;
      // paint guid line side dot at ring inner border
      // UIStarModel star = stars[i];
      // Color color = starsColorMap[star.star]!;
      Color color = Colors.black87;
      if (i == 0) {
        color = Colors.red;
      }

      Offset inRingXY = calculatePointOnCircle(innerRadius, angle - 15);
      Offset outRingXY = calculatePointOnCircle(outerRadius, angle - 15);

      final zeroLinePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5;
      canvas.drawLine(inRingXY, outRingXY, zeroLinePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RingSheetPainter oldDelegate) {
    return innerRadius != oldDelegate.innerRadius ||
        outerRadius != oldDelegate.outerRadius;
  }
}
