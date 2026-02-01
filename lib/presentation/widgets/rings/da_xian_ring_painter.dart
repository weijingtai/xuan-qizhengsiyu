import 'dart:math' as math;

import 'package:common/module.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/utils/da_xian_calculate_helper.dart';

import '../../../enums/enum_twelve_gong.dart';


class DaXianRingPainter extends CustomPainter {
  final double startAngle;
  final double sweepRadian;
  final double baseRadian;
  final Color color;
  final double outerRadius;
  final double innerRadius;
  // final double eachSlotBorderWidth;
  // final double gongBorderWidth;

  // 修改：使用YearMonth类型
  Map<EnumTwelveGong, YearMonth> gongYearsMapper;
  List<EnumTwelveGong> gongOrderedSeq;

  final Border? gongBorder;
  final Border? slotBorder;
  final Color? gongBackgroundColor;
  final Color? slotBackgroundColor;

  final TextStyle? textStyle;
  // 修改：使用YearMonth类型
  final YearMonth startFromYear;

  DaXianRingPainter({
    required this.startAngle,
    required this.sweepRadian,
    required this.color,
    required this.outerRadius,
    required this.innerRadius,
    required this.gongYearsMapper,
    // this.eachSlotBorderColor = Colors.black12,
    // this.eachSlotBorderWidth = 1.0,
    // this.gongBorderColors = Colors.black87,
    // this.gongBorderWidth = 1.0,
    this.gongBorder,
    this.gongBackgroundColor,
    this.slotBackgroundColor,
    this.slotBorder,
    required this.textStyle,
    required this.gongOrderedSeq,
    required this.startFromYear,
  }) : baseRadian = startAngle * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    double eachGongAngle = 360 / gongYearsMapper.length;
    // 修改：使用YearMonth计算
    YearMonth prevBaseYear = startFromYear - YearMonth.oneYear();

    List<List<double>> generateDrawAngles =
        generateDrawAngle(gongYearsMapper, eachGongAngle);

    List<List<YearMonth>> eachGongSlotsList =
        generateDrawYearMonthList(gongYearsMapper);

    for (var i = 0; i < gongOrderedSeq.length; i++) {
      YearMonth gongYears = gongYearsMapper[gongOrderedSeq[i]]!;
      double gongStartAngle = startAngle + eachGongAngle * i;
      double gongEndAngle = startAngle + eachGongAngle * (i + 1);
      prevBaseYear = printEachGongV2(canvas, center, outerRect, innerRect,
          gongIndex: i,
          totalSlot: gongYears,
          starAngle: gongStartAngle,
          endAngle: gongEndAngle,
          slotDrawAngleList: generateDrawAngles[i],
          slotYearMonthList: eachGongSlotsList[i]!,
          baseYear: prevBaseYear);
    }
  }

  List<List<YearMonth>> generateDrawYearMonthList(
      Map<EnumTwelveGong, YearMonth> gongYearsMapper) {
    List<YearMonth> ordersGongYearsList = [];
    for (var element in gongOrderedSeq) {
      YearMonth gongYears = gongYearsMapper[element]!;
      ordersGongYearsList.add(gongYears);
    }
    return DaXianCalculateHelper.transformYearMonths(ordersGongYearsList);
  }

  List<List<double>> generateDrawAngle(
      Map<EnumTwelveGong, YearMonth> gongYearsMapper, double eachGongAngle) {
    List<double> eachGongTotalsYear = [];

    for (var element in gongOrderedSeq) {
      YearMonth gongYears = gongYearsMapper[element]!;
      eachGongTotalsYear.add(
          gongYears.year + DaXianRingPainter.monthsToDouble(gongYears.month));
    }

    List<List<double>> gongYearAsDoubleList =
        DaXianCalculateHelper.transformNumbers(eachGongTotalsYear);

    List<List<double>> result = [];
    double prevTail = 0;
    for (int i = 0; i < gongYearAsDoubleList.length; i++) {
      List<double> gongYearDoubleList = gongYearAsDoubleList[i];
      // 拆分第一个 最后一个元素
      double firstElement = gongYearDoubleList.first;
      double lastElement = gongYearDoubleList.last;
      // 截取出第一个元素与最后一个元素
      gongYearDoubleList.removeAt(0);
      gongYearDoubleList.removeLast();
      // 统计一共有多少个槽位
      int totalSlotCount = gongYearDoubleList.length;
      (bool, double, List<double>, double) res =
          DaXianCalculateHelper.proportionalAllocationWithEnds(
              first: firstElement,
              last: lastElement,
              kMiddle: totalSlotCount,
              total: eachGongAngle);
      result.add([res.$2, ...res.$3, res.$4]);

      prevTail = res.$4;
    }

    return result;
  }

  static double monthsToDouble(int months) {
    int years = months ~/ 12;
    int monthsLeft = months % 12;

    double monthInDouble = 0.0;
    if (monthsLeft == 0) {
      return 0.0;
    } else if (monthsLeft <= 4) {
      monthInDouble = 0.25;
    } else if (monthsLeft <= 8) {
      monthInDouble = 0.5;
    } else if (monthsLeft <= 11) {
      monthInDouble = 0.75;
    }
    return years + monthInDouble;
  }

  _drawBackground(Canvas canvas,
      {required Offset center,
      required Rect outerRect,
      required Rect innerRect,
      required double startRadians,
      required double sweepRadians,
      required double radius,
      required int index,
      required Color color}) {
    final Paint fillPaint = Paint()..color = color.withAlpha(index * 10 + 50);
    final Path fillPath = Path()
      ..moveTo(center.dx + innerRadius * math.cos(startRadians),
          center.dy + innerRadius * math.sin(startRadians))
      ..arcTo(outerRect, startRadians, sweepRadians, false)
      ..arcTo(innerRect, startRadians + sweepRadians, -sweepRadians, false)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
  }

  _drawBorder(
    Canvas canvas, {
    required Offset center,
    required Rect outerRect,
    required Rect innerRect,
    required double startRadians,
    required double sweepRadians,
    required double innerRadius,
    required double outerRadius,
    required Border border,
    // required Color borderColor, // 新增边框颜色参数
    // required double borderWidth, // 新增边框宽度参数
    // required int index,
  }) {
    // final Paint borderPaint = Paint()
    //   ..color = borderColor
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = borderWidth;

    // 绘制外弧线
    if (border.bottom != BorderSide.none) {
      final Paint borderPaint = Paint()
        ..color = border.bottom.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = border.bottom.width;
      canvas.drawArc(outerRect, startRadians, sweepRadians, false, borderPaint);
    }
    // 绘制内弧线
    if (border.top != BorderSide.none) {
      final Paint borderPaint = Paint()
        ..color = border.top.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = border.top.width;
      canvas.drawArc(innerRect, startRadians, sweepRadians, false, borderPaint);
    }

    if (border.left != BorderSide.none) {
      final Paint borderPaint = Paint()
        ..color = border.left.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = border.left.width;
      // 绘制两条径向边线
      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(startRadians + sweepRadians),
            center.dy + innerRadius * math.sin(startRadians + sweepRadians)),
        Offset(center.dx + outerRadius * math.cos(startRadians + sweepRadians),
            center.dy + outerRadius * math.sin(startRadians + sweepRadians)),
        borderPaint,
      );
    }
    if (border.right != BorderSide.none) {
      final Paint borderPaint = Paint()
        ..color = border.right.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = border.right.width;

      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(startRadians),
            center.dy + innerRadius * math.sin(startRadians)),
        Offset(center.dx + outerRadius * math.cos(startRadians),
            center.dy + outerRadius * math.sin(startRadians)),
        borderPaint,
      );
    }
  }

  // 修改：printEachGong方法签名
  YearMonth printEachGongV2(
      Canvas canvas, Offset center, Rect outerRect, Rect innerRect,
      {required int gongIndex,
      required YearMonth totalSlot,
      required double starAngle,
      required double endAngle,
      required List<double> slotDrawAngleList,
      required List<YearMonth> slotYearMonthList,
      required YearMonth baseYear}) {
    YearMonth newYearMonth = baseYear;
    double gongAngle = endAngle - starAngle;
    double sweepRadians = gongAngle * math.pi / 180;
    double startRadians = starAngle * math.pi / 180;

    _drawGongBackground(canvas, center, outerRect, innerRect, startRadians,
        sweepRadians, gongIndex);

    double prevSlotRadians = 0 * math.pi / 180 + startRadians;
    for (var i = 0; i < slotDrawAngleList.length; i++) {
      double angle = slotDrawAngleList[i];
      double slotSweepRadians = angle * math.pi / 180;
      double slotStartRadians = prevSlotRadians;
      prevSlotRadians = slotStartRadians + slotSweepRadians;

      if (i == slotDrawAngleList.length - 1) {
        newYearMonth = newYearMonth + slotYearMonthList[i];
        if (slotYearMonthList[i].year == 0) {
          newYearMonth = newYearMonth + YearMonth.oneYear();
          // 确保添加的数字是正确的
        }
      } else if (i == 0) {
        if (newYearMonth.month != 0) {
          newYearMonth = YearMonth(newYearMonth.year, 12 - newYearMonth.month);
        } else {
          newYearMonth = newYearMonth + slotYearMonthList[i];
        }
      } else {
        newYearMonth = newYearMonth + slotYearMonthList[i];
      }
      paintEachSlot(canvas,
          index: i,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          slotStartRadians: slotStartRadians,
          slotSweepRadians: slotSweepRadians,
          newYearMonth: newYearMonth);
      if (i == 0 && gongIndex != 0) {
        newYearMonth = YearMonth(newYearMonth.year, 0);
      }
    }

    return newYearMonth;
  }

  void paintEachSlot(
    Canvas canvas, {
    required int index,
    required Offset center,
    required Rect outerRect,
    required Rect innerRect,
    required double slotStartRadians,
    required double slotSweepRadians,
    required YearMonth newYearMonth,
  }) {
    if (slotBackgroundColor != null) {
      _drawBackground(canvas,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          startRadians: slotStartRadians,
          sweepRadians: slotSweepRadians,
          index: index,
          radius: innerRadius,
          color: slotBackgroundColor!);
    }

    if (slotBorder != null) {
      _drawBorder(
        canvas,
        center: center,
        outerRect: outerRect,
        innerRect: innerRect,
        startRadians: slotStartRadians,
        sweepRadians: slotSweepRadians,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        border: slotBorder!,
      );
    }
    if (textStyle != null) {
      printSlotText(canvas,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          startRadians: slotStartRadians,
          sweepRadians: slotSweepRadians,
          index: index,
          yearMoth: newYearMonth);
    }
  }

  void printSlotText(Canvas canvas,
      {required Offset center,
      required Rect outerRect,
      required Rect innerRect,
      required double startRadians,
      required double sweepRadians,
      required int index,
      required YearMonth yearMoth}) {
    // 计算扇形的角度中心（弧度）
    double sectorCenterAngle = startRadians + sweepRadians / 2;

    // 计算径向中心
    double middleRadius = (innerRadius + outerRadius) / 2;

    // 扇环的几何中心点
    final Offset sectorCenter = Offset(
      center.dx + middleRadius * math.cos(sectorCenterAngle),
      center.dy + middleRadius * math.sin(sectorCenterAngle),
    );

    // 保存canvas状态
    canvas.save();
    // 将canvas原点移动到扇环中心点
    canvas.translate(sectorCenter.dx, sectorCenter.dy);

    // 绘制文字
    // final YearMonth _baseYear = baseYear + currentYear;
    String yearMonthContent = yearMoth.year.toString();
    if (yearMoth.month != 0) {
      yearMonthContent += "/${yearMoth.month}";
    }
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: yearMonthContent,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final Offset textOffset =
        Offset(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    // 恢复canvas状态
    canvas.restore();
  }

  void _drawGongBackground(Canvas canvas, Offset center, Rect outerRect,
      Rect innerRect, double startRadians, double sweepRadians, int gongIndex) {
    // 绘制填充扇形
    if (gongBackgroundColor != null) {
      _drawBackground(canvas,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          startRadians: startRadians,
          sweepRadians: sweepRadians,
          radius: innerRadius,
          index: gongIndex,
          color: gongBackgroundColor!);
    }

    // 绘制扇形边框
    if (gongBorder != null) {
      _drawBorder(canvas,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          startRadians: startRadians,
          sweepRadians: sweepRadians,
          innerRadius: innerRadius,
          outerRadius: outerRadius,
          border: gongBorder!);
    }
  }

  @override
  bool shouldRepaint(covariant DaXianRingPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepRadian != sweepRadian ||
        oldDelegate.color != color ||
        oldDelegate.outerRadius != outerRadius ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.gongBorder != gongBorder ||
        oldDelegate.slotBorder != slotBorder;
  }
}
