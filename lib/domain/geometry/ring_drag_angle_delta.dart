import 'dart:math';
import 'dart:ui';

/// 纯几何环形拖拽角度增量库 — ①层。
///
/// 给定环心坐标、半径、起止指针位置，算出相对起始角的角度增量（弧度，带符号）。
/// 顺时针拖拽返回负值，逆时针返回正值。
/// 自动处理跨 0°/360° 边界（如从 350° 拖到 10°，返回 20° 而非 -340°）。
///
/// 零业务依赖，只 import dart:math 和 Flutter 基础几何类型，
/// 不依赖任何 qizhengsiyu 包内类型。
///
/// 迁移属性：天然可迁移，以后原样搬进 chart-ui。
double calculateRingDragAngleDelta({
  required Offset ringCenter,
  required double radius,
  required Offset startPointer,
  required Offset endPointer,
}) {
  final startAngle = atan2(
    startPointer.dy - ringCenter.dy,
    startPointer.dx - ringCenter.dx,
  );
  final endAngle = atan2(
    endPointer.dy - ringCenter.dy,
    endPointer.dx - ringCenter.dx,
  );

  double delta = endAngle - startAngle;

  if (delta > pi) {
    delta -= 2 * pi;
  } else if (delta < -pi) {
    delta += 2 * pi;
  }

  return delta;
}
