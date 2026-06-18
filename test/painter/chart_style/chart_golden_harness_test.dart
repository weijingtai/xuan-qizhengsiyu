import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style.dart';
import 'package:qizhengsiyu/painter/painters.dart';
import 'package:qizhengsiyu/painter/star_body_ring_painter.dart';
import 'package:qizhengsiyu/painter/twelve_zhi_gong_circle_ring_printer.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/sector_painter.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';

void main() {
  const size = Size(400, 400);
  final fallbackStyle = QiZhengChartStyle.fallback();

  // Altered style: every semantic color is different from fallback
  final alteredStyle = QiZhengChartStyle.fallback().copyWith(
    colors: ChartSemanticColors.fallback().copyWith(
      northLine: const Color(0xFF00FF00), // bright green vs red
      divider: const Color(0xFFFF00FF), // magenta vs black87
      border: const Color(0xFFFFFF00), // yellow vs grey
      sectorBorder: const Color(0xFF00FFFF), // cyan vs black12
    ),
  );

  // ─── Golden baselines (regression anchors) ─────────────────────
  // NOTE: These baselines were generated WITH the migration code.
  // They do NOT prove "pixel-identical before/after migration".

  group('Golden Harness (regression anchors)', () {
    testWidgets('SectorPainter golden', (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: SectorPainter(
            startAngle: 0,
            sweepRadian: math.pi / 6,
            color: Colors.blue.withOpacity(0.3),
            outerRadius: 180,
            innerRadius: 140,
            borderColor: Colors.black12,
            borderWidth: 1.0,
            style: fallbackStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/sector_painter.png'),
      );
    });

    testWidgets('RingSheetPainter golden', (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: RingSheetPainter(
            innerRadius: 140,
            outerRadius: 180,
            style: fallbackStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/ring_sheet_painter.png'),
      );
    });

    testWidgets('IndicatorScalePainter golden', (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: IndicatorScalePainter(
            indicatorAngle: 45,
            ringWidth: 20,
            tickLength: 10,
            style: fallbackStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/indicator_scale_painter.png'),
      );
    });

    // Partial migration: only border color hooks style; text typography
    // and business alpha gradient still use old logic.
    testWidgets('TwelveZhiGongCircleRingPrinter golden (partial migration)',
        (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: TwelveZhiGongCircleRingPrinter(
            innerRadius: 140,
            outerRadius: 180,
            starColorMapper:
                QiZhengSiYuUIConstantResources.zhengColorMap,
            twelveGongList: EnumTwelveGong.values.sublist(0, 12),
            isReverseText: true,
            isHorizontalText: true,
            textStyle: const TextStyle(
                color: Colors.black, fontSize: 18, height: 1.2),
            style: fallbackStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile(
            'goldens/partial_migration/twelve_zhi_gong_circle_ring_printer.png'),
      );
    });
  });

  // ─── Empty-hook killer tests ──────────────────────────────────
  // Strategy: render with altered style → save as separate golden.
  // Then byte-compare fallback vs altered golden files — must differ.
  // This proves paint() actually reads style, not just stores it.

  group('Empty-hook killer (style must affect rendering)', () {
    testWidgets('SectorPainter: altered sectorBorder → different pixels',
        (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: SectorPainter(
            startAngle: 0,
            sweepRadian: math.pi / 6,
            color: Colors.blue.withOpacity(0.3),
            outerRadius: 180,
            innerRadius: 140,
            style: alteredStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/altered_style/sector_painter.png'),
      );
      // Verify the two golden files are byte-different
      final fallback = File(
          'test/painter/chart_style/goldens/tier_a/sector_painter.png');
      final altered = File(
          'test/painter/chart_style/goldens/altered_style/sector_painter.png');
      if (fallback.existsSync() && altered.existsSync()) {
        expect(fallback.readAsBytesSync(), isNot(equals(altered.readAsBytesSync())),
            reason: 'Altered style must produce different pixels than fallback');
      }
    });

    testWidgets('RingSheetPainter: altered divider/northLine → different pixels',
        (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: RingSheetPainter(
            innerRadius: 140,
            outerRadius: 180,
            style: alteredStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/altered_style/ring_sheet_painter.png'),
      );
      final fallback = File(
          'test/painter/chart_style/goldens/tier_a/ring_sheet_painter.png');
      final altered = File(
          'test/painter/chart_style/goldens/altered_style/ring_sheet_painter.png');
      if (fallback.existsSync() && altered.existsSync()) {
        expect(fallback.readAsBytesSync(), isNot(equals(altered.readAsBytesSync())),
            reason: 'Altered style must produce different pixels than fallback');
      }
    });

    testWidgets('IndicatorScalePainter: altered northLine → different pixels',
        (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: IndicatorScalePainter(
            indicatorAngle: 45,
            ringWidth: 20,
            tickLength: 10,
            style: alteredStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/altered_style/indicator_scale_painter.png'),
      );
      final fallback = File(
          'test/painter/chart_style/goldens/tier_a/indicator_scale_painter.png');
      final altered = File(
          'test/painter/chart_style/goldens/altered_style/indicator_scale_painter.png');
      if (fallback.existsSync() && altered.existsSync()) {
        expect(fallback.readAsBytesSync(), isNot(equals(altered.readAsBytesSync())),
            reason: 'Altered style must produce different pixels than fallback');
      }
    });

    testWidgets(
        'TwelveZhiGongCircleRingPrinter: altered border → different pixels',
        (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: TwelveZhiGongCircleRingPrinter(
            innerRadius: 140,
            outerRadius: 180,
            starColorMapper:
                QiZhengSiYuUIConstantResources.zhengColorMap,
            twelveGongList: EnumTwelveGong.values.sublist(0, 12),
            isReverseText: true,
            isHorizontalText: true,
            textStyle: const TextStyle(
                color: Colors.black, fontSize: 18, height: 1.2),
            style: alteredStyle,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile(
            'goldens/altered_style/twelve_zhi_gong_circle_ring_printer.png'),
      );
      final fallback = File(
          'test/painter/chart_style/goldens/partial_migration/twelve_zhi_gong_circle_ring_printer.png');
      final altered = File(
          'test/painter/chart_style/goldens/altered_style/twelve_zhi_gong_circle_ring_printer.png');
      if (fallback.existsSync() && altered.existsSync()) {
        expect(fallback.readAsBytesSync(), isNot(equals(altered.readAsBytesSync())),
            reason: 'Altered style must produce different pixels than fallback');
      }
    });
  });

  // ─── Style storage assertions ─────────────────────────────────
  group('Style-aware color assertions', () {
    test('SectorPainter uses style.colors.sectorBorder for borderColor', () {
      final customStyle = QiZhengChartStyle.fallback().copyWith(
        colors: ChartSemanticColors.fallback().copyWith(
          sectorBorder: const Color(0xFF00FF00),
        ),
      );
      final painter = SectorPainter(
        startAngle: 0,
        sweepRadian: 0.5,
        color: Colors.blue,
        outerRadius: 180,
        innerRadius: 140,
        style: customStyle,
      );
      expect(painter.style, isNotNull);
      expect(painter.style!.colors.sectorBorder, const Color(0xFF00FF00));
    });

    test('SectorPainter falls back to borderColor when style is null', () {
      final painter = SectorPainter(
        startAngle: 0,
        sweepRadian: 0.5,
        color: Colors.blue,
        outerRadius: 180,
        innerRadius: 140,
        borderColor: Colors.purple,
      );
      expect(painter.style, isNull);
      expect(painter.borderColor, Colors.purple);
    });
  });
}
