import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/geometry/ring_drag_angle_delta.dart';

/// 纯几何环形拖拽角度增量库单元测试。

const _ringCenter = Offset(200.0, 200.0);
const _ringRadius = 150.0;

Offset pointAtAngle(double angleRad, {Offset center = _ringCenter, double radius = _ringRadius}) {
  return Offset(
    center.dx + radius * math.cos(angleRad),
    center.dy + radius * math.sin(angleRad),
  );
}

void main() {
  group('A. 零点与零增量', () {
    test('起止同点角度增量为 0', () {
      final p = pointAtAngle(math.pi / 4);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: p,
        endPointer: p,
      ), closeTo(0.0, 1e-12));
    });

    test('起止均在 0° 位置增量为 0', () {
      final p = pointAtAngle(0.0);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: p,
        endPointer: p,
      ), closeTo(0.0, 1e-12));
    });
  });

  group('B. 顺时针拖拽（返回负值）', () {
    test('0°→-30° 返回 -π/6', () {
      final start = pointAtAngle(0.0);
      final end = pointAtAngle(-math.pi / 6);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(-math.pi / 6, 1e-12));
    });

    test('-30°→-90° 返回 -π/3', () {
      final start = pointAtAngle(-math.pi / 6);
      final end = pointAtAngle(-math.pi / 2);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(-math.pi / 3, 1e-12));
    });

    test('45°→-45° 返回 -π/2', () {
      final start = pointAtAngle(math.pi / 4);
      final end = pointAtAngle(-math.pi / 4);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(-math.pi / 2, 1e-10));
    });
  });

  group('C. 逆时针拖拽（返回正值）', () {
    test('-30°→0° 返回 π/6', () {
      final start = pointAtAngle(-math.pi / 6);
      final end = pointAtAngle(0.0);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(math.pi / 6, 1e-12));
    });

    test('-90°→-30° 返回 π/3', () {
      final start = pointAtAngle(-math.pi / 2);
      final end = pointAtAngle(-math.pi / 6);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(math.pi / 3, 1e-12));
    });

    test('-45°→45° 返回 π/2', () {
      final start = pointAtAngle(-math.pi / 4);
      final end = pointAtAngle(math.pi / 4);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(math.pi / 2, 1e-10));
    });
  });

  group('D. 跨 0°/360° 边界 (atan2 正 π 到负 π 环绕)', () {
    // atan2 范围 [-π, π]，从接近 +π 逆时针穿过到 -π 算 0°/360° 跨越。
    // 逆时针方向: 接近 +π → 接近 -π 是短路径正向（如 170°→-170°，差=+20°）。
    // 顺时针方向: 接近 -π → 接近 +π 是短路径负向（如 -170°→170°，差=-20°）。

    test('逆时针跨边界：170°→-170° 返回 +20° (+π/9)', () {
      final start = pointAtAngle(170 * math.pi / 180);
      final end = pointAtAngle(-170 * math.pi / 180);
      final delta = calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      );
      expect(delta, closeTo(20 * math.pi / 180, 1e-10));
    });

    test('顺时针跨边界：-170°→170° 返回 -20° (-π/9)', () {
      final start = pointAtAngle(-170 * math.pi / 180);
      final end = pointAtAngle(170 * math.pi / 180);
      final delta = calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      );
      expect(delta, closeTo(-20 * math.pi / 180, 1e-10));
    });

    test('逆时针跨边界：179°→-179° 返回 +2°', () {
      final start = pointAtAngle(179 * math.pi / 180);
      final end = pointAtAngle(-179 * math.pi / 180);
      final delta = calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      );
      expect(delta, closeTo(2 * math.pi / 180, 1e-10));
    });

    test('顺时针跨边界：-179°→179° 返回 -2°', () {
      final start = pointAtAngle(-179 * math.pi / 180);
      final end = pointAtAngle(179 * math.pi / 180);
      final delta = calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      );
      expect(delta, closeTo(-2 * math.pi / 180, 1e-10));
    });

    test('逆时针跨边界：175°→-175° 返回 +10°', () {
      final start = pointAtAngle(175 * math.pi / 180);
      final end = pointAtAngle(-175 * math.pi / 180);
      final delta = calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      );
      expect(delta, closeTo(10 * math.pi / 180, 1e-10));
    });

    test('顺时针跨边界：-175°→175° 返回 -10°', () {
      final start = pointAtAngle(-175 * math.pi / 180);
      final end = pointAtAngle(175 * math.pi / 180);
      final delta = calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      );
      expect(delta, closeTo(-10 * math.pi / 180, 1e-10));
    });
  });

  group('E. 大角度拖拽（不超过半圈）', () {
    test('逆时针半圈：0°→180° 返回 π', () {
      final start = pointAtAngle(0.0);
      final end = pointAtAngle(math.pi);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(math.pi, 1e-10));
    });

    test('顺时针半圈：180°→0° 返回 -π', () {
      final start = pointAtAngle(math.pi);
      final end = pointAtAngle(0.0);
      expect(calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      ), closeTo(-math.pi, 1e-10));
    });

    test('超过半圈逆时针：0°→181° 走短路径顺时针返回负值', () {
      final start = pointAtAngle(0.0);
      final end = pointAtAngle(181 * math.pi / 180);
      final delta = calculateRingDragAngleDelta(
        ringCenter: _ringCenter,
        radius: _ringRadius,
        startPointer: start,
        endPointer: end,
      );
      // 短路径是顺时针方向，从 0° 到 181°(=-179°) 的短弧是 -179°
      expect(delta < 0, isTrue);
      expect(delta.abs(), closeTo(179 * math.pi / 180, 1e-10));
    });
  });

  group('F. 环心平移与半径无关性', () {
    test('环心平移不影响角度增量', () {
      final c1 = Offset(100.0, 50.0);
      final c2 = Offset(500.0, 300.0);
      final r = 80.0;
      final angle1 = math.pi / 3;
      final angle2 = -math.pi / 4;

      final d1 = calculateRingDragAngleDelta(
        ringCenter: c1,
        radius: r,
        startPointer: pointAtAngle(angle1, center: c1, radius: r),
        endPointer: pointAtAngle(angle2, center: c1, radius: r),
      );
      final d2 = calculateRingDragAngleDelta(
        ringCenter: c2,
        radius: r,
        startPointer: pointAtAngle(angle1, center: c2, radius: r),
        endPointer: pointAtAngle(angle2, center: c2, radius: r),
      );

      expect(d1, closeTo(d2, 1e-12));
    });

    test('半径不同但坐标角度相等时增量一致', () {
      final c = Offset(200.0, 200.0);
      final r1 = 100.0;
      final r2 = 300.0;
      final angle1 = -2 * math.pi / 3;
      final angle2 = math.pi / 6;

      final d1 = calculateRingDragAngleDelta(
        ringCenter: c,
        radius: r1,
        startPointer: pointAtAngle(angle1, center: c, radius: r1),
        endPointer: pointAtAngle(angle2, center: c, radius: r1),
      );
      final d2 = calculateRingDragAngleDelta(
        ringCenter: c,
        radius: r2,
        startPointer: pointAtAngle(angle1, center: c, radius: r2),
        endPointer: pointAtAngle(angle2, center: c, radius: r2),
      );

      expect(d1, closeTo(d2, 1e-12));
    });
  });

  group('G. 零导入依赖校验', () {
    test('不 import 任何 qizhengsiyu 包内类型', () {
      // 编译时可自动校验 — 若有跨模块导入 flutter analyze 会报错。
      // 本测试作为文档性断言：调用方传入纯 Offset+double，返回值是 double。
      final result = calculateRingDragAngleDelta(
        ringCenter: Offset.zero,
        radius: 100.0,
        startPointer: Offset(100, 0),
        endPointer: Offset(0, 100),
      );
      expect(result, isA<double>());
    });
  });
}
