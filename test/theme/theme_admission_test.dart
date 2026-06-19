import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/theme_loader.dart';
import 'package:xuan_config/xuan_config.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style.dart'
    hide TokenLoader;

/// Compare Color values (ignoring MaterialColor/Color type differences)
void expectColorEquals(Color actual, Color expected, {String? reason}) {
  expect(actual.toARGB32(), equals(expected.toARGB32()), reason: reason);
}

/// Compare ChartSemanticColors field-by-field
void expectSemanticColorsEquals(
    ChartSemanticColors actual, ChartSemanticColors expected) {
  expectColorEquals(actual.ringStroke, expected.ringStroke, reason: 'ringStroke');
  expectColorEquals(actual.divider, expected.divider, reason: 'divider');
  expectColorEquals(actual.border, expected.border, reason: 'border');
  expectColorEquals(actual.shadow, expected.shadow, reason: 'shadow');
  expectColorEquals(actual.scaleTick, expected.scaleTick, reason: 'scaleTick');
  expectColorEquals(actual.scaleTickAccent, expected.scaleTickAccent,
      reason: 'scaleTickAccent');
  expectColorEquals(actual.labelDefault, expected.labelDefault,
      reason: 'labelDefault');
  expectColorEquals(actual.labelMuted, expected.labelMuted, reason: 'labelMuted');
  expectColorEquals(actual.annotationYin, expected.annotationYin,
      reason: 'annotationYin');
  expectColorEquals(actual.annotationSu, expected.annotationSu,
      reason: 'annotationSu');
  expectColorEquals(actual.sectorBorder, expected.sectorBorder,
      reason: 'sectorBorder');
  expectColorEquals(actual.northLine, expected.northLine, reason: 'northLine');
}

/// Full chart YAML that matches DefaultXuanThemeData fallback values.
const _chartYaml = '''
light:
  components: {}
  chart:
    colors:
      ringStroke: "#000000"
      divider: "#DD000000"
      border: "#9E9E9E"
      shadow: "#61000000"
      scaleTick: "#DD000000"
      scaleTickAccent: "#448AFF"
      labelDefault: "#000000"
      labelMuted: "#73000000"
      annotationYin: "#73000000"
      annotationSu: "#F44336"
      sectorBorder: "#1F000000"
      northLine: "#F44336"
    typography:
      constellationName: {family: MaShanZheng, fontSize: 16.0, fontWeight: normal, height: 1.0}
      starName: {family: NotoSansSC, fontSize: 24.0, fontWeight: normal, height: 1.0}
      gongName: {family: NotoSansSC, fontSize: 18.0, fontWeight: normal, height: 1.2}
      degree: {family: NotoSansSC, fontSize: 14.0, fontWeight: w400, height: 1.0}
      yearMonth: {family: NotoSansSC, fontSize: 10.0, fontWeight: normal, height: 1.0}
      shenSha: {family: NotoSansSC, fontSize: 14.0, fontWeight: normal, height: 1.0}
    geometry:
      ringStrokeWidth: 0.5
      tickLength: 5.0
      longTickLength: 10.0
      innerPadding: 12.0
      outerPadding: 12.0
      guideDotRadius: 2.0
      starHolderRadius: 6.0
    starPalette:
      zheng:
        Sun: "#433C2D"
        Moon: "#D6ECF0"
        Mars: "#E95464"
        Saturn: "#A88462"
        Mercury: "#4C8DAE"
        Jupiter: "#549688"
        Venus: "#F0A72E"
      stars:
        Sun: "#FFA400"
        Moon: "#A1AFC9"
        Mars: "#E95464"
        Saturn: "#896C39"
        Mercury: "#4C8DAE"
        Jupiter: "#549688"
        Venus: "#F2BE45"
        Qi: "#8D4BBB"
        Bei: "#425066"
        Ji: "#D3B17D"
        Luo: "#B35C44"
dark:
  components: {}
  chart:
    colors:
      ringStroke: "#000000"
      divider: "#DD000000"
      border: "#9E9E9E"
      shadow: "#61000000"
      scaleTick: "#DD000000"
      scaleTickAccent: "#448AFF"
      labelDefault: "#000000"
      labelMuted: "#73000000"
      annotationYin: "#73000000"
      annotationSu: "#F44336"
      sectorBorder: "#1F000000"
      northLine: "#F44336"
    typography:
      constellationName: {family: MaShanZheng, fontSize: 16.0, fontWeight: normal, height: 1.0}
      starName: {family: NotoSansSC, fontSize: 24.0, fontWeight: normal, height: 1.0}
      gongName: {family: NotoSansSC, fontSize: 18.0, fontWeight: normal, height: 1.2}
      degree: {family: NotoSansSC, fontSize: 14.0, fontWeight: w400, height: 1.0}
      yearMonth: {family: NotoSansSC, fontSize: 10.0, fontWeight: normal, height: 1.0}
      shenSha: {family: NotoSansSC, fontSize: 14.0, fontWeight: normal, height: 1.0}
    geometry:
      ringStrokeWidth: 0.5
      tickLength: 5.0
      longTickLength: 10.0
      innerPadding: 12.0
      outerPadding: 12.0
      guideDotRadius: 2.0
      starHolderRadius: 6.0
    starPalette:
      zheng:
        Sun: "#433C2D"
        Moon: "#D6ECF0"
        Mars: "#E95464"
        Saturn: "#A88462"
        Mercury: "#4C8DAE"
        Jupiter: "#549688"
        Venus: "#F0A72E"
      stars:
        Sun: "#FFA400"
        Moon: "#A1AFC9"
        Mars: "#E95464"
        Saturn: "#896C39"
        Mercury: "#4C8DAE"
        Jupiter: "#549688"
        Venus: "#F2BE45"
        Qi: "#8D4BBB"
        Bei: "#425066"
        Ji: "#D3B17D"
        Luo: "#B35C44"
''';

void main() {
  group('Theme Admission Tests', () {
    group('DefaultXuanThemeData.chartTokens → ThemeChartStyleResolver → QiZhengChartStyle', () {
      test('DefaultXuanThemeData.chartTokens produces style matching fallback', () {
        final chartTokens = DefaultXuanThemeData.themeSet.light.chartTokens;
        expect(chartTokens, isNotNull);

        final resolver = ThemeChartStyleResolver.fromTokens(chartTokens!);
        final style = resolver.resolve(Brightness.light);
        final fallback = QiZhengChartStyle.fallback();

        expectSemanticColorsEquals(style.colors, fallback.colors);
        expect(style.typography, equals(fallback.typography));
        expect(style.geometry, equals(fallback.geometry));
      });

      test('DefaultXuanThemeData.chartTokens produces palette matching fallback', () {
        final chartTokens = DefaultXuanThemeData.themeSet.light.chartTokens;
        expect(chartTokens, isNotNull);

        final resolver = ThemeChartStyleResolver.fromTokens(chartTokens!);
        final palette = resolver.resolvePalette(Brightness.light);
        final fallbackPalette = QiZhengStarPalette.fallback();

        expect(palette, equals(fallbackPalette));
      });
    });

    group('ChartThemeTokens completeness', () {
      test('DefaultXuanThemeData has all required color keys', () {
        final chartTokens = DefaultXuanThemeData.themeSet.light.chartTokens;
        expect(chartTokens, isNotNull);
        final colors = chartTokens!.colors;

        const requiredColorKeys = [
          'ringStroke', 'divider', 'border', 'shadow',
          'scaleTick', 'scaleTickAccent', 'labelDefault', 'labelMuted',
          'annotationYin', 'annotationSu', 'sectorBorder', 'northLine',
        ];
        for (final key in requiredColorKeys) {
          expect(colors.containsKey(key), isTrue,
              reason: 'Missing color key: $key');
        }
      });

      test('DefaultXuanThemeData has all required typography keys', () {
        final chartTokens = DefaultXuanThemeData.themeSet.light.chartTokens;
        expect(chartTokens, isNotNull);
        final typography = chartTokens!.typography;

        const requiredTypoKeys = [
          'constellationName', 'starName', 'gongName',
          'degree', 'yearMonth', 'shenSha',
        ];
        for (final key in requiredTypoKeys) {
          expect(typography.containsKey(key), isTrue,
              reason: 'Missing typography key: $key');
          final role = typography[key];
          expect(role, isA<Map>(), reason: 'Typography key $key is not a map');
          final roleMap = role as Map;
          expect(roleMap.containsKey('family'), isTrue,
              reason: 'Missing family in $key');
          expect(roleMap.containsKey('fontSize'), isTrue,
              reason: 'Missing fontSize in $key');
          expect(roleMap.containsKey('fontWeight'), isTrue,
              reason: 'Missing fontWeight in $key');
          expect(roleMap.containsKey('height'), isTrue,
              reason: 'Missing height in $key');
        }
      });

      test('DefaultXuanThemeData has all required geometry keys', () {
        final chartTokens = DefaultXuanThemeData.themeSet.light.chartTokens;
        expect(chartTokens, isNotNull);
        final geometry = chartTokens!.geometry;

        const requiredGeoKeys = [
          'ringStrokeWidth', 'tickLength', 'longTickLength',
          'innerPadding', 'outerPadding', 'guideDotRadius', 'starHolderRadius',
        ];
        for (final key in requiredGeoKeys) {
          expect(geometry.containsKey(key), isTrue,
              reason: 'Missing geometry key: $key');
        }
      });

      test('DefaultXuanThemeData has starPalette with zheng and stars', () {
        final chartTokens = DefaultXuanThemeData.themeSet.light.chartTokens;
        expect(chartTokens, isNotNull);
        final starPalette = chartTokens!.starPalette;

        expect(starPalette.containsKey('zheng'), isTrue,
            reason: 'Missing starPalette.zheng');
        expect(starPalette.containsKey('stars'), isTrue,
            reason: 'Missing starPalette.stars');

        final zheng = starPalette['zheng'] as Map;
        const requiredZhengKeys = [
          'Sun', 'Moon', 'Mars', 'Saturn', 'Mercury', 'Jupiter', 'Venus',
        ];
        for (final key in requiredZhengKeys) {
          expect(zheng.containsKey(key), isTrue,
              reason: 'Missing zheng star: $key');
        }

        final stars = starPalette['stars'] as Map;
        const requiredStarsKeys = [
          'Sun', 'Moon', 'Mars', 'Saturn', 'Mercury', 'Jupiter', 'Venus',
          'Qi', 'Bei', 'Ji', 'Luo',
        ];
        for (final key in requiredStarsKeys) {
          expect(stars.containsKey(key), isTrue,
              reason: 'Missing star: $key');
        }
      });
    });

    group('Unified pipeline: YAML → ConfigRepository → TokenLoader → XuanThemeSet → ThemeChartStyleResolver', () {
      test('round-trip: MemoryConfigSource with chart YAML produces matching style',
          () async {
        final source = MemoryConfigSource({'theme.yaml': _chartYaml});
        final repository = ConfigRepository(source: source);
        final themeSet = await TokenLoader.loadSetOrDefault(
          repository: repository,
          path: 'theme.yaml',
        );

        // Extract chartTokens from light theme
        final chartTokens = themeSet.light.chartTokens;
        expect(chartTokens, isNotNull,
            reason: 'chartTokens should not be null after YAML load');

        // Resolve to QiZhengChartStyle
        final resolver = ThemeChartStyleResolver.fromTokens(chartTokens!);
        final style = resolver.resolve(Brightness.light);
        final fallback = QiZhengChartStyle.fallback();

        // Should match fallback since YAML values are the same
        expectSemanticColorsEquals(style.colors, fallback.colors);
        expect(style.typography, equals(fallback.typography));
        expect(style.geometry, equals(fallback.geometry));
      });

      test('round-trip: palette from MemoryConfigSource matches fallback', () async {
        final source = MemoryConfigSource({'theme.yaml': _chartYaml});
        final repository = ConfigRepository(source: source);
        final themeSet = await TokenLoader.loadSetOrDefault(
          repository: repository,
          path: 'theme.yaml',
        );

        final chartTokens = themeSet.light.chartTokens;
        expect(chartTokens, isNotNull);

        final resolver = ThemeChartStyleResolver.fromTokens(chartTokens!);
        final palette = resolver.resolvePalette(Brightness.light);
        final fallbackPalette = QiZhengStarPalette.fallback();

        expect(palette, equals(fallbackPalette));
      });

      test('round-trip: dark theme also resolves correctly', () async {
        final source = MemoryConfigSource({'theme.yaml': _chartYaml});
        final repository = ConfigRepository(source: source);
        final themeSet = await TokenLoader.loadSetOrDefault(
          repository: repository,
          path: 'theme.yaml',
        );

        final chartTokens = themeSet.dark.chartTokens;
        expect(chartTokens, isNotNull);

        final resolver = ThemeChartStyleResolver.fromTokens(chartTokens!);
        final style = resolver.resolve(Brightness.dark);
        final fallback = QiZhengChartStyle.fallback(brightness: Brightness.dark);

        expectSemanticColorsEquals(style.colors, fallback.colors);
        expect(style.typography, equals(fallback.typography));
        expect(style.geometry, equals(fallback.geometry));
        expect(style.brightness, equals(Brightness.dark));
      });

      test('fallback: missing YAML path falls back to DefaultXuanThemeData',
          () async {
        final source = MemoryConfigSource({}); // empty — no files
        final repository = ConfigRepository(source: source);
        final themeSet = await TokenLoader.loadSetOrDefault(
          repository: repository,
          path: 'nonexistent.yaml',
        );

        // Should fall back to DefaultXuanThemeData
        expect(themeSet, equals(DefaultXuanThemeData.themeSet));
      });
    });
  });
}
