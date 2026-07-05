
import 'package:flutter/material.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QiZhengChartStyle.fallback() parity', () {
    late QiZhengChartStyle style;

    setUp(() {
      style = QiZhengChartStyle.fallback();
    });

    test('semantic colors match §1 hardcoded anchors', () {
      expect(style.colors.ringStroke, Colors.black);
      expect(style.colors.divider, Colors.black87);
      expect(style.colors.border, Colors.grey);
      expect(style.colors.shadow, Colors.black38);
      expect(style.colors.scaleTick, Colors.black87);
      expect(style.colors.scaleTickAccent, Colors.blueAccent);
      expect(style.colors.labelDefault, Colors.black);
      expect(style.colors.labelMuted, Colors.black45);
      expect(style.colors.annotationYin, Colors.black45);
      expect(style.colors.annotationSu, Colors.red);
      expect(style.colors.sectorBorder, Colors.black12);
      expect(style.colors.northLine, Colors.red);
    });

    test('typography constellation name matches star_xiu_ring_painter anchor',
        () {
      final role = style.typography.constellationName;
      expect(role.family, 'MaShanZheng');
      expect(role.fontSize, 16.0);
      expect(role.height, 1.0);
      expect(role.fontWeight, FontWeight.normal);
    });

    test('typography star name matches star_track_ring / star_body_ring anchor',
        () {
      final role = style.typography.starName;
      expect(role.family, 'NotoSansSC');
      expect(role.fontSize, 24.0);
      expect(role.height, 1.0);
      expect(role.fontWeight, FontWeight.normal);
    });

    test('typography gong name matches twelve_zhi_gong_circle_ring_printer anchor',
        () {
      final role = style.typography.gongName;
      expect(role.family, 'NotoSansSC');
      expect(role.fontSize, 18.0);
      expect(role.height, 1.2);
      expect(role.fontWeight, FontWeight.normal);
    });

    test('typography degree matches center_text_circle_widget anchor', () {
      final role = style.typography.degree;
      expect(role.family, 'NotoSansSC');
      expect(role.fontSize, 14.0);
      expect(role.height, 1.0);
    });

    test('typography year month matches da_xian_ring_painter anchor', () {
      final role = style.typography.yearMonth;
      expect(role.family, 'NotoSansSC');
      expect(role.fontSize, 10.0);
      expect(role.height, 1.0);
      expect(role.fontWeight, FontWeight.normal);
    });

    test('geometry matches §1.4 hardcoded anchors', () {
      expect(style.geometry.ringStrokeWidth, 0.5);
      expect(style.geometry.tickLength, 5.0);
      expect(style.geometry.longTickLength, 10.0);
      expect(style.geometry.innerPadding, 12.0);
      expect(style.geometry.outerPadding, 12.0);
      expect(style.geometry.guideDotRadius, 2.0);
      expect(style.geometry.starHolderRadius, 6.0);
    });

    test('brightness defaults to light', () {
      expect(style.brightness, Brightness.light);
    });
  });

  group('QiZhengStarPalette.fallback() parity', () {
    late QiZhengStarPalette palette;

    setUp(() {
      palette = QiZhengStarPalette.fallback();
    });

    test('zhengColorMap matches QiZhengSiYuUIConstantResources.zhengColorMap', () {
      final sourceMap = QiZhengSiYuUIConstantResources.zhengColorMap;
      for (final star in sourceMap.keys) {
        expect(palette.zhengColor(star), sourceMap[star]!,
            reason: 'zhengColor mismatch for ${star.name}');
      }
    });

    test('starsColorMap matches QiZhengSiYuUIConstantResources.starsColorMap', () {
      final sourceMap = QiZhengSiYuUIConstantResources.starsColorMap;
      for (final star in sourceMap.keys) {
        expect(palette.starColor(star), sourceMap[star]!,
            reason: 'starColor mismatch for ${star.name}');
      }
    });

    test('unknown star falls back gracefully', () {
      final unknownStarColor = palette.zhengColor(EnumStars.Qi);
      expect(unknownStarColor, isNotNull);
      final unknownStarColor2 = palette.starColor(EnumStars.Sun);
      expect(unknownStarColor2, isNotNull);
    });
  });

  group('QiZhengChartStyle immutability', () {
    test('copyWith preserves unchanged fields', () {
      final original = QiZhengChartStyle.fallback();
      final copied = original.copyWith(brightness: Brightness.dark);
      expect(copied.colors, original.colors);
      expect(copied.typography, original.typography);
      expect(copied.geometry, original.geometry);
      expect(copied.brightness, Brightness.dark);
      expect(copied, isNot(equals(original)));
    });

    test('== and hashCode work correctly', () {
      final a = QiZhengChartStyle.fallback();
      final b = QiZhengChartStyle.fallback();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ChartStyleResolver', () {
    test('FallbackChartStyleResolver returns fallback style', () {
      const resolver = FallbackChartStyleResolver();
      final style = resolver.resolve(Brightness.light);
      expect(style, equals(QiZhengChartStyle.fallback()));
    });

    test('FallbackChartStyleResolver returns fallback palette', () {
      const resolver = FallbackChartStyleResolver();
      final palette = resolver.resolvePalette(Brightness.light);
      expect(palette, equals(QiZhengStarPalette.fallback()));
    });
  });

  group('ChartSemanticColors fallback field-level anchors', () {
    test('constellation name text style anchor (star_xiu_ring_painter:141)',
        () {
      final style = QiZhengChartStyle.fallback();
      final textStyle = style.typography.constellationName.toTextStyle(
        color: const Color.fromRGBO(55, 53, 52, 1),
        shadows: [
          BoxShadow(
            color: Colors.black38.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1),
          )
        ],
      );
      expect(textStyle.fontSize, 16.0);
      expect(textStyle.color, const Color.fromRGBO(55, 53, 52, 1));
      expect(textStyle.fontFamily, 'MaShanZheng');
    });

    test('indicator scale paint anchor (painters.dart:228)', () {
      final style = QiZhengChartStyle.fallback();
      expect(style.colors.scaleTick, Colors.black87);
      expect(style.colors.northLine, Colors.red);
    });

    test('ring sheet divider anchor (star_body_ring_painter.dart:434)', () {
      final style = QiZhengChartStyle.fallback();
      expect(style.colors.divider, Colors.black87);
    });

    test('sector border anchor (sector_painter.dart:22)', () {
      final style = QiZhengChartStyle.fallback();
      expect(style.colors.sectorBorder, Colors.black12);
    });
  });
}
