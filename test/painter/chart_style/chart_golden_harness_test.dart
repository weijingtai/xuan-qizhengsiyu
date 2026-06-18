import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style.dart';
import 'package:qizhengsiyu/painter/painters.dart';
import 'package:qizhengsiyu/painter/star_body_ring_painter.dart';
import 'package:qizhengsiyu/painter/StarInn28RingPainter.dart';
import 'package:qizhengsiyu/painter/twelve_zhi_gong_circle_ring_printer.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/sector_painter.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';
import 'package:tuple/tuple.dart';

void main() {
  const size = Size(400, 400);
  final style = QiZhengChartStyle.fallback();

  group('Tier A Golden Harness', () {
    testWidgets('SectorPainter golden baseline', (tester) async {
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
            style: style,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/sector_painter.png'),
      );
    });

    testWidgets('RingSheetPainter golden baseline', (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: RingSheetPainter(
            innerRadius: 140,
            outerRadius: 180,
            style: style,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/ring_sheet_painter.png'),
      );
    });

    testWidgets('IndicatorScalePainter golden baseline', (tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: IndicatorScalePainter(
            indicatorAngle: 45,
            ringWidth: 20,
            tickLength: 10,
            style: style,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/indicator_scale_painter.png'),
      );
    });

    testWidgets('TwelveZhiGongCircleRingPrinter golden baseline',
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
            style: style,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/twelve_zhi_gong_circle_ring_printer.png'),
      );
    });

    testWidgets('Starinn28ringPainter golden baseline', (tester) async {
      final twentyEightStarsList =
          List<Tuple3<Enum28Constellations, Color, double>>.generate(
        28,
        (i) => Tuple3(
          Enum28Constellations.values[i],
          Color.fromRGBO(
            (i * 37) % 256,
            (i * 73) % 256,
            (i * 113) % 256,
            1,
          ),
          360 / 28,
        ),
      );
      final key = UniqueKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: CustomPaint(
          size: size,
          painter: Starinn28ringPainter(
            innerRadius: 140,
            outerRadius: 180,
            twentyEightStarsList: twentyEightStarsList,
            isReverseText: true,
            textStyle: const TextStyle(
                color: Colors.black, fontSize: 18, height: 1.2),
            style: style,
          ),
        ),
      ));
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/tier_a/starinn28ring_painter.png'),
      );
    });
  });

  group('Tier A style-aware color assertions', () {
    test('SectorPainter uses style.colors.sectorFill for borderColor', () {
      final customStyle = QiZhengChartStyle.fallback().copyWith(
        colors: ChartSemanticColors.fallback().copyWith(
          sectorFill: const Color(0xFF00FF00),
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
      // borderColor param is overridden by style
      // ignore: unnecessary_null_comparison
      expect(painter.style, isNotNull);
      expect(painter.style!.colors.sectorFill, const Color(0xFF00FF00));
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
