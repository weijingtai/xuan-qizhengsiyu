import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 主界面结构
class CircleIndicatorWidget extends StatelessWidget {
  const CircleIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // 隔离静态层
      child: Stack(
        children: [
          // 背景层（静态刻度圆环）
          CustomPaint(
            painter: StaticRingPainter(),
            isComplex: true, // 标记为复杂绘制
            willChange: false,
          ),
          // 运动层（小球+指示线）
          // RepaintBoundary( // 独立重绘层
          //   child: CustomPaint(
          //     painter: DynamicElementsPainter(),
          //     // 启用重绘优化
          //     foregroundPainter: null,
          //   ),
          // ),
          RepaintBoundary(
            // 独立重绘层
            child: CustomPaint(
              // painter: OptimizedCirclePainter(
              //   originalAngles: [12, 13, 15, 240, 355],
              //   ringRadius: 120,
              //   trackRadius: 160,
              //   ballRadius: 8,
              //   minGap: 4,
              // ),
              painter: CollisionAvoidancePainter([11, 11, 12, 12]),
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityBall {
  final double angle;
  final int priority; // 1-4（1为最高优先级）

  PriorityBall(this.angle, this.priority);
}

class PriorityCollisionPainter extends CustomPainter {
  late final List<PriorityBall> balls;
  final double minAngleDiff = 8.0;
  final double trackRadius = 160;
  final double ringRadius = 120;

  @override
  void paint(Canvas canvas, Size size) {
    final adjusted = _resolveCollisions();
    // _drawAllElements(canvas, size.center(Offset.zero), adjusted);
    _drawAdjustedBalls(canvas, size.center(Offset.zero), adjusted);
    _drawGuidelines(canvas, size.center(Offset.zero), adjusted);
  }

  // 新指示线绘制逻辑
  void _drawGuidelines(
      Canvas canvas, Offset center, List<PriorityBall> adjustedAngles) {
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 1.5;

    for (int i = 0; i < adjustedAngles.length; i++) {
      // final originalAngle = originalAngles[i];
      // final adjustedAngle = adjustedAngles[i];

      // 计算刻度线连接点
      final tickEnd = _calculateTickEnd(adjustedAngles[i].angle, center);

      // 计算小球位置
      final ballPos = _calculateBallPosition(adjustedAngles[i].angle, center);

      // 绘制连接线
      canvas.drawLine(ballPos, tickEnd, linePaint);
    }
  }

  // 计算刻度线终点
  Offset _calculateTickEnd(double angle, Offset center) {
    final radians = angle * pi / 180;
    final isMainTick = (angle % 15) == 0;
    final tickLength = isMainTick ? 12.0 : 8.0;
    final radius = ringRadius + tickLength;

    return Offset(
          radius * cos(radians),
          radius * sin(radians),
        ) +
        center;
  }

  // 绘制避让后的小球
  void _drawAdjustedBalls(
      Canvas canvas, Offset center, List<PriorityBall> adjustedAngles) {
    final ballPaint = Paint()
      ..color = Colors.blue
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final angle in adjustedAngles) {
      final pos = _calculateBallPosition(angle.angle, center);
      canvas.drawCircle(pos, 8, ballPaint);
    }
  } // 计算小球位置

  Offset _calculateBallPosition(double angle, Offset center) {
    final radians = angle * pi / 180;
    return Offset(
          trackRadius * cos(radians),
          trackRadius * sin(radians),
        ) +
        center;
  }

  List<PriorityBall> _resolveCollisions() {
    final sortedBalls = List<PriorityBall>.from(balls)
      ..sort((a, b) => a.angle.compareTo(b.angle));

    final adjustedBalls = <PriorityBall>[];
    final conflictMap = <int, bool>{};

    for (int i = 0; i < sortedBalls.length; i++) {
      final current = sortedBalls[i];
      if (adjustedBalls.isEmpty) {
        adjustedBalls.add(current);
        continue;
      }

      final prev = adjustedBalls.last;
      final diff = _circularDistance(prev.angle, current.angle);

      if (diff < minAngleDiff) {
        final resolved = _handleCollision(prev, current, conflictMap);
        adjustedBalls.add(resolved);
      } else {
        adjustedBalls.add(current);
      }
    }

    return adjustedBalls;
  }

  // 环形最短距离计算
  double _circularDistance(double a, double b) {
    double rawDiff = (b - a).abs();
    return min(rawDiff, 360 - rawDiff);
  }

  PriorityBall _handleCollision(
      PriorityBall prev, PriorityBall current, Map<int, bool> conflictMap) {
    // 优先级比较
    if (current.priority > prev.priority) {
      return _adjustLowerPriority(current, prev, conflictMap);
    } else if (current.priority == prev.priority) {
      return _adjustSamePriority(current, prev, conflictMap);
    }
    return current;
  }

  PriorityBall _adjustLowerPriority(
      PriorityBall lower, PriorityBall higher, Map<int, bool> conflictMap) {
    // 低优先级小球避让
    final adjustDir = conflictMap[higher.hashCode] ?? true;
    final newAngle = higher.angle + (adjustDir ? minAngleDiff : -minAngleDiff);
    conflictMap[lower.hashCode] = !adjustDir;

    return PriorityBall(newAngle % 360, lower.priority);
  }

  PriorityBall _adjustSamePriority(
      PriorityBall a, PriorityBall b, Map<int, bool> conflictMap) {
    // 对称避让
    final adjustDir = conflictMap[b.hashCode] ?? false;
    final newAngle = a.angle + (adjustDir ? minAngleDiff : -minAngleDiff);
    conflictMap[a.hashCode] = !adjustDir;

    return PriorityBall(newAngle % 360, a.priority);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

// 其余绘制方法与之前类似...
}

class OptimizedCirclePainter extends CustomPainter {
  // 可配置参数
  final List<double> originalAngles;
  final double ringRadius; // 刻度圆环半径
  final double trackRadius; // 小球轨道半径
  final double ballRadius; // 小球半径
  final double minGap; // 最小可视间距（像素）
  final Color indicatorColor;

  // 计算属性
  double get _minAngleDiff => _calculateMinAngleDiff();

  OptimizedCirclePainter({
    required this.originalAngles,
    this.ringRadius = 120,
    this.trackRadius = 160,
    this.ballRadius = 8,
    this.minGap = 4,
    this.indicatorColor = Colors.blue,
  });

  // 核心避让算法
  List<double> _calculateAdjustedAngles() {
    final sortedAngles = [...originalAngles]..sort();
    List<double> adjusted = [];

    for (int i = 0; i < sortedAngles.length; i++) {
      final current = sortedAngles[i];
      if (adjusted.isEmpty) {
        adjusted.add(current);
        continue;
      }

      // 环形角度差计算
      final prev = adjusted.last;
      final diff = _circularAngleDiff(prev, current);

      if (diff < _minAngleDiff) {
        final adjustedAngle = _findClosestValidAngle(prev, current);
        adjusted.add(adjustedAngle % 360);
      } else {
        adjusted.add(current);
      }
    }
    return adjusted;
  }

  // 动态阈值计算
  double _calculateMinAngleDiff() {
    final numerator = 2 * ballRadius + minGap;
    if (numerator >= 2 * trackRadius) return 360;

    final radians = 2 * asin(numerator / (2 * trackRadius));
    return (radians * 180 / pi).clamp(2.0, 45.0);
  }

  // 环形最短角度差
  double _circularAngleDiff(double a, double b) {
    final rawDiff = (b - a).abs();
    return min(rawDiff, 360 - rawDiff);
  }

  // 寻找最近有效角度
  double _findClosestValidAngle(double prev, double current) {
    final clockwise = (prev + _minAngleDiff) % 360;
    final counterClockwise = (prev - _minAngleDiff) % 360;

    final cwDist = _circularAngleDiff(current, clockwise);
    final ccwDist = _circularAngleDiff(current, counterClockwise);

    return cwDist < ccwDist ? clockwise : counterClockwise;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final adjustedAngles = _calculateAdjustedAngles();

    _drawGuidelines(canvas, center);
    _drawAdjustedBalls(canvas, center, adjustedAngles);
  }

  // 绘制指示系统
  // void _drawGuidelines(Canvas canvas, Offset center) {
  //   final linePaint = Paint()
  //     ..color = indicatorColor.withOpacity(0.5)
  //     ..strokeWidth = 1.5;
  //
  //   for (final angle in originalAngles) {
  //     final tickEnd = _tickPosition(angle, center);
  //     final ballPos = _adjustedBallPosition(angle, center);
  //
  //     // 绘制曲线路径避免交叉
  //     final path = Path()
  //       ..moveTo(ballPos.dx, ballPos.dy)
  //       ..quadraticBezierTo(
  //           center.dx,
  //           center.dy,
  //           tickEnd.dx,
  //           tickEnd.dy
  //       );
  //
  //     canvas.drawPath(path, linePaint);
  //   }
  // }
  void _drawGuidelines(Canvas canvas, Offset center) {
    final linePaint = Paint()
      ..color = indicatorColor.withOpacity(0.5)
      ..strokeWidth = 1.5;

    for (final angle in originalAngles) {
      // 刻度线外端点
      final tickEnd = _calculateTickEnd(angle, center);

      // 小球实际位置
      final ballPos = _calculateBallPosition(angle, center);

      // 绘制直线连接
      canvas.drawLine(ballPos, tickEnd, linePaint);
    }
  }

  // 计算刻度线外端点
  Offset _calculateTickEnd(double angle, Offset center) {
    final radians = angle * pi / 180;
    final isMain = (angle % 15).abs() < 0.1;
    final tickLength = isMain ? 12.0 : 8.0;

    return Offset(
          (ringRadius + tickLength) * cos(radians),
          (ringRadius + tickLength) * sin(radians),
        ) +
        center;
  }

  // 计算小球位置（使用调整后的角度）
  Offset _calculateBallPosition(double angle, Offset center) {
    final radians = angle * pi / 180;
    return Offset(
          trackRadius * cos(radians),
          trackRadius * sin(radians),
        ) +
        center;
  }

  // 刻度线终点计算
  // Offset _tickPosition(double angle, Offset center) {
  //   final radians = angle * pi / 180;
  //   final isMainTick = (angle % 15).abs() < 0.1;
  //   final tickLength = isMainTick ? 12.0 : 8.0;
  //
  //   return Offset(
  //     (ringRadius + tickLength) * cos(radians),
  //     (ringRadius + tickLength) * sin(radians),
  //   ) + center;
  // }

  // 调整后小球位置
  Offset _adjustedBallPosition(double angle, Offset center) {
    final radians = angle * pi / 180;
    return Offset(
          trackRadius * cos(radians),
          trackRadius * sin(radians),
        ) +
        center;
  }

  // 绘制小球系统
  void _drawAdjustedBalls(Canvas canvas, Offset center, List<double> angles) {
    final ballPaint = Paint()
      ..color = indicatorColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final angle in angles) {
      final pos = _adjustedBallPosition(angle, center);
      canvas.drawCircle(pos, ballRadius, ballPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OptimizedCirclePainter old) =>
      originalAngles != old.originalAngles ||
      ringRadius != old.ringRadius ||
      trackRadius != old.trackRadius ||
      ballRadius != old.ballRadius ||
      minGap != old.minGap ||
      indicatorColor != old.indicatorColor;
}

// 使用示例

// 静态圆环绘制（带优化标记）
class StaticRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.grey[300]!;

    // 绘制基础圆环
    canvas.drawCircle(center, 120, ringPaint);

    // 绘制刻度（每5度一个刻度）
    for (int degree = 0; degree < 360; degree += 5) {
      final radians = degreeToRadians(degree.toDouble());
      final start = Offset(120 * cos(radians), 120 * sin(radians)) + center;

      final isMainTick = degree % 15 == 0;
      final tickLength = isMainTick ? 12.0 : 8.0;

      final end = Offset((120 + tickLength) * cos(radians),
              (120 + tickLength) * sin(radians)) +
          center;

      canvas.drawLine(start, end,
          Paint()..color = isMainTick ? Colors.black87 : Colors.grey);
    }
  }

  // 静态层永远不需要重绘
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 动态元素绘制（带性能优化）
class DynamicElementsPainter extends CustomPainter {
  final List<double> ballAngles = [0, 15, 24.5];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const trackRadius = 160.0; // 轨道半径

    // 预计算路径对象
    final trackPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: trackRadius));

    // 绘制轨道
    canvas.drawPath(
        trackPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.grey.withOpacity(0.3));

    // 绘制小球及指示线
    for (final angle in ballAngles) {
      final radians = degreeToRadians(angle);
      final ballPos =
          Offset(trackRadius * cos(radians), trackRadius * sin(radians)) +
              center;

      // 指示线
      canvas.drawLine(
          center,
          ballPos,
          Paint()
            ..color = Colors.blue.withOpacity(0.3)
            ..strokeWidth = 1);

      // 小球
      canvas.drawCircle(
          ballPos,
          6,
          Paint()
            ..color = Colors.blue
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  // 只有当角度数组变化时重绘
  @override
  bool shouldRepaint(covariant DynamicElementsPainter oldDelegate) {
    return !listEquals(oldDelegate.ballAngles, ballAngles);
  }
}

class CollisionAvoidancePainter extends CustomPainter {
  final List<double> originalAngles;
  final double minAngleDiff = 8.0;
  final double trackRadius = 160;
  final double ringRadius = 120;

  CollisionAvoidancePainter(this.originalAngles);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final adjustedAngles = _calculateAdjustedAngles();

    // 绘制所有元素
    _drawGuidelines(canvas, center, adjustedAngles);
    _drawAdjustedBalls(canvas, center, adjustedAngles);
  }

  // 改进后的避让算法（保持原始顺序）
  List<double> _calculateAdjustedAngles() {
    List<double> adjusted = [];

    for (int i = 0; i < originalAngles.length; i++) {
      double current = originalAngles[i];
      if (adjusted.isEmpty) {
        adjusted.add(current);
        continue;
      }

      double prev = adjusted[i - 1];
      // 环形最短距离计算
      double diff = _circularDistance(prev, current);

      if (diff < minAngleDiff) {
        // 沿环形顺时针方向偏移
        double adjust = (prev + minAngleDiff) % 360;
        adjusted.add(adjust);
      } else {
        adjusted.add(current);
      }
    }
    return adjusted;
  }

  // 环形最短距离计算
  double _circularDistance(double a, double b) {
    double rawDiff = (b - a).abs();
    return min(rawDiff, 360 - rawDiff);
  }

  // 新指示线绘制逻辑
  void _drawGuidelines(
      Canvas canvas, Offset center, List<double> adjustedAngles) {
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 1.5;

    for (int i = 0; i < originalAngles.length; i++) {
      final originalAngle = originalAngles[i];
      final adjustedAngle = adjustedAngles[i];

      // 计算刻度线连接点
      final tickEnd = _calculateTickEnd(originalAngle, center);

      // 计算小球位置
      final ballPos = _calculateBallPosition(adjustedAngle, center);

      // 绘制连接线
      canvas.drawLine(ballPos, tickEnd, linePaint);
    }
  }

  // 计算刻度线终点
  Offset _calculateTickEnd(double angle, Offset center) {
    final radians = angle * pi / 180;
    final isMainTick = (angle % 15) == 0;
    final tickLength = isMainTick ? 12.0 : 8.0;
    final radius = ringRadius + tickLength;

    return Offset(
          radius * cos(radians),
          radius * sin(radians),
        ) +
        center;
  }

  // 计算小球位置
  Offset _calculateBallPosition(double angle, Offset center) {
    final radians = angle * pi / 180;
    return Offset(
          trackRadius * cos(radians),
          trackRadius * sin(radians),
        ) +
        center;
  }

  // 绘制避让后的小球
  void _drawAdjustedBalls(Canvas canvas, Offset center, List<double> angles) {
    final ballPaint = Paint()
      ..color = Colors.blue
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final angle in angles) {
      final pos = _calculateBallPosition(angle, center);
      canvas.drawCircle(pos, 8, ballPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CollisionAvoidancePainter old) =>
      !listEquals(originalAngles, old.originalAngles);
}

// class CollisionAvoidancePainter extends CustomPainter {
//   final List<double> originalAngles; // 原始角度列表
//   final double minAngleDiff = 8.0; // 最小可视角度差
//   final double trackRadius = 160;
//
//   CollisionAvoidancePainter(this.originalAngles);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = size.center(Offset.zero);
//     final adjustedAngles = _calculateAdjustedAngles();
//
//     // 绘制所有指示线（始终使用原始角度）
//     _drawGuidelines(canvas, center);
//
//     // 绘制调整后的小球
//     _drawAdjustedBalls(canvas, center, adjustedAngles);
//   }
//
//   // 核心避让算法
//   List<double> _calculateAdjustedAngles() {
//     List<double> sorted = List.from(originalAngles)..sort();
//     List<double> adjusted = [];
//
//     // 处理首尾循环差值
//     if (sorted.last - sorted.first > 360 - minAngleDiff) {
//       final overflow = sorted.where((a) => a > 360 - minAngleDiff);
//       final underflow = sorted.where((a) => a <= minAngleDiff);
//       sorted = [...overflow.map((a) => a - 360), ...underflow]..sort();
//     }
//
//     // 角度避让调整
//     for (int i = 0; i < sorted.length; i++) {
//       if (i == 0) {
//         adjusted.add(sorted[i]);
//         continue;
//       }
//
//       double prev = adjusted[i-1];
//       double current = sorted[i];
//
//       // 当角度差不足时进行偏移
//       if (current - prev < minAngleDiff) {
//         double adjust = prev + minAngleDiff;
//         // 确保不超过原始角度范围
//         adjust = min(adjust, current + minAngleDiff/2);
//         adjusted.add(adjust);
//       } else {
//         adjusted.add(current);
//       }
//     }
//
//     return adjusted.map((a) => a % 360).toList();
//   }
//
//   // 绘制真实角度指示线
//   void _drawGuidelines(Canvas canvas, Offset center) {
//     final paint = Paint()
//       ..color = Colors.blue.withOpacity(0.2)
//       ..strokeWidth = 1;
//
//     for (final angle in originalAngles) {
//       final radians = angle * pi / 180;
//       final end = Offset(
//           trackRadius * cos(radians),
//           trackRadius * sin(radians)
//       ) + center;
//
//       canvas.drawLine(center, end, paint);
//     }
//   }
//
//   // 绘制避让后的小球
//   void _drawAdjustedBalls(Canvas canvas, Offset center, List<double> angles) {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
//
//     for (final angle in angles) {
//       final radians = angle * pi / 180;
//       final position = Offset(
//           trackRadius * cos(radians),
//           trackRadius * sin(radians)
//       ) + center;
//
//       canvas.drawCircle(position, 8, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CollisionAvoidancePainter old) =>
//       !listEquals(originalAngles, old.originalAngles);
// }
// 角度转换工具
double degreeToRadians(double degree) => degree * pi / 180;
