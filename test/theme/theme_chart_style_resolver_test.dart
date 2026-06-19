import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:theme/theme.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style.dart';

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

void main() {
  group('ThemeChartStyleResolver', () {
    group('fromTokens with fallback-matching tokens', () {
      test('produces QiZhengChartStyle matching fallback', () {
        final resolver = ThemeChartStyleResolver.fromTokens(
          DefaultXuanThemeData.themeSet.light.chartTokens!,
        );
        final style = resolver.resolve(Brightness.light);
        final fallback = QiZhengChartStyle.fallback();

        expectSemanticColorsEquals(style.colors, fallback.colors);
        expect(style.typography, equals(fallback.typography));
        expect(style.geometry, equals(fallback.geometry));
      });

      test('produces QiZhengStarPalette matching fallback', () {
        final resolver = ThemeChartStyleResolver.fromTokens(
          DefaultXuanThemeData.themeSet.light.chartTokens!,
        );
        final palette = resolver.resolvePalette(Brightness.light);
        final fallbackPalette = QiZhengStarPalette.fallback();

        for (final star in fallbackPalette.zhengColorMap.keys) {
          expectColorEquals(
            palette.zhengColor(star),
            fallbackPalette.zhengColor(star),
            reason: 'zheng $star mismatch',
          );
        }
        for (final star in fallbackPalette.starsColorMap.keys) {
          expectColorEquals(
            palette.starColor(star),
            fallbackPalette.starColor(star),
            reason: 'stars $star mismatch',
          );
        }
      });
    });

    group('fromTokens with altered tokens', () {
      test('produces different style when tokens differ', () {
        const alteredTokens = ChartThemeTokens(
          colors: {
            'ringStroke': '#FF0000',
            'divider': '#00FF00',
            'border': '#0000FF',
            'shadow': '#111111',
            'scaleTick': '#222222',
            'scaleTickAccent': '#333333',
            'labelDefault': '#444444',
            'labelMuted': '#555555',
            'annotationYin': '#666666',
            'annotationSu': '#777777',
            'sectorBorder': '#888888',
            'northLine': '#999999',
          },
          typography: {
            'constellationName': {
              'family': 'TestFont',
              'fontSize': 20.0,
              'fontWeight': 'bold',
              'height': 1.5,
            },
            'starName': {
              'family': 'TestFont',
              'fontSize': 30.0,
              'fontWeight': 'bold',
              'height': 1.5,
            },
            'gongName': {
              'family': 'TestFont',
              'fontSize': 22.0,
              'fontWeight': 'bold',
              'height': 1.5,
            },
            'degree': {
              'family': 'TestFont',
              'fontSize': 16.0,
              'fontWeight': 'bold',
              'height': 1.5,
            },
            'yearMonth': {
              'family': 'TestFont',
              'fontSize': 12.0,
              'fontWeight': 'bold',
              'height': 1.5,
            },
            'shenSha': {
              'family': 'TestFont',
              'fontSize': 16.0,
              'fontWeight': 'bold',
              'height': 1.5,
            },
          },
          geometry: {
            'ringStrokeWidth': 2.0,
            'tickLength': 8.0,
            'longTickLength': 15.0,
            'innerPadding': 20.0,
            'outerPadding': 20.0,
            'guideDotRadius': 4.0,
            'starHolderRadius': 10.0,
          },
          starPalette: {
            'zheng': {'Sun': '#FF0000'},
            'stars': {'Sun': '#00FF00'},
          },
        );

        final resolver = ThemeChartStyleResolver.fromTokens(alteredTokens);
        final style = resolver.resolve(Brightness.light);
        final fallback = QiZhengChartStyle.fallback();

        // Colors should differ from fallback
        expect(style.colors.ringStroke.toARGB32(), equals(0xFFFF0000));
        expect(style.colors.northLine.toARGB32(), equals(0xFF999999));

        // Typography should differ
        expect(style.typography.constellationName.family, equals('TestFont'));
        expect(style.typography.constellationName.fontSize, equals(20.0));
        expect(style.typography.constellationName.fontWeight, equals(FontWeight.w700));

        // Geometry should differ
        expect(style.geometry.ringStrokeWidth, equals(2.0));
        expect(style.geometry.tickLength, equals(8.0));

        // Overall style should not equal fallback
        expect(style, isNot(equals(fallback)));
      });
    });

    group('fromTokens with empty tokens', () {
      test('falls back to fallback style', () {
        final resolver =
            ThemeChartStyleResolver.fromTokens(ChartThemeTokens.empty);
        final style = resolver.resolve(Brightness.light);
        final fallback = QiZhengChartStyle.fallback();

        expect(style, equals(fallback));
      });

      test('falls back to fallback palette', () {
        final resolver =
            ThemeChartStyleResolver.fromTokens(ChartThemeTokens.empty);
        final palette = resolver.resolvePalette(Brightness.light);
        final fallbackPalette = QiZhengStarPalette.fallback();

        expect(palette, equals(fallbackPalette));
      });
    });

    group('parity with FallbackChartStyleResolver', () {
      test('fromTokens with default chart tokens produces identical style',
          () {
        final resolver = ThemeChartStyleResolver.fromTokens(
          DefaultXuanThemeData.themeSet.light.chartTokens!,
        );
        const fallbackResolver = FallbackChartStyleResolver();

        final themeStyle = resolver.resolve(Brightness.light);
        final fallbackStyle = fallbackResolver.resolve(Brightness.light);

        expectSemanticColorsEquals(themeStyle.colors, fallbackStyle.colors);
        expect(themeStyle.typography, equals(fallbackStyle.typography));
        expect(themeStyle.geometry, equals(fallbackStyle.geometry));
        expect(themeStyle.brightness, equals(fallbackStyle.brightness));
      });

      test('fromTokens with default chart tokens produces identical palette',
          () {
        final resolver = ThemeChartStyleResolver.fromTokens(
          DefaultXuanThemeData.themeSet.light.chartTokens!,
        );
        const fallbackResolver = FallbackChartStyleResolver();

        final themePalette = resolver.resolvePalette(Brightness.light);
        final fallbackPalette = fallbackResolver.resolvePalette(Brightness.light);

        expect(themePalette, equals(fallbackPalette));
      });
    });

    group('brightness forwarding', () {
      test('resolve forwards brightness to output style', () {
        final resolver = ThemeChartStyleResolver.fromTokens(
          DefaultXuanThemeData.themeSet.light.chartTokens!,
        );
        final darkStyle = resolver.resolve(Brightness.dark);
        expect(darkStyle.brightness, equals(Brightness.dark));
      });
    });

    group('star palette parsing', () {
      test('parses all zheng stars from default tokens', () {
        final resolver = ThemeChartStyleResolver.fromTokens(
          DefaultXuanThemeData.themeSet.light.chartTokens!,
        );
        final palette = resolver.resolvePalette(Brightness.light);

        // Default tokens have 7 zheng stars
        const expectedZheng = [
          EnumStars.Sun,
          EnumStars.Moon,
          EnumStars.Mars,
          EnumStars.Saturn,
          EnumStars.Mercury,
          EnumStars.Jupiter,
          EnumStars.Venus,
        ];
        for (final star in expectedZheng) {
          expect(palette.zhengColorMap.containsKey(star), isTrue,
              reason: 'Missing zheng star: $star');
        }
      });

      test('parses all stars from default tokens', () {
        final resolver = ThemeChartStyleResolver.fromTokens(
          DefaultXuanThemeData.themeSet.light.chartTokens!,
        );
        final palette = resolver.resolvePalette(Brightness.light);

        // Default tokens have 11 stars
        const expectedStars = [
          EnumStars.Sun,
          EnumStars.Moon,
          EnumStars.Mars,
          EnumStars.Saturn,
          EnumStars.Mercury,
          EnumStars.Jupiter,
          EnumStars.Venus,
          EnumStars.Qi,
          EnumStars.Bei,
          EnumStars.Ji,
          EnumStars.Luo,
        ];
        for (final star in expectedStars) {
          expect(palette.starsColorMap.containsKey(star), isTrue,
              reason: 'Missing star: $star');
        }
      });
    });
  });
}
