// ignore_for_file: deprecated_member_use_from_same_package
// This file deliberately tests deprecated ChartTokenLoader/ChartStarPaletteLoader API.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style.dart';

/// 比较两个 Color 的值（忽略 MaterialColor/Color 类型差异）
/// 使用 toARGB32() 代替已废弃的 .value
void expectColorEquals(Color actual, Color expected, {String? reason}) {
  expect(actual.toARGB32(), equals(expected.toARGB32()), reason: reason);
}

/// 比较 ChartSemanticColors 的所有字段值
void expectSemanticColorsEquals(
    ChartSemanticColors actual, ChartSemanticColors expected) {
  expectColorEquals(actual.ringStroke, expected.ringStroke, reason: 'ringStroke');
  expectColorEquals(actual.divider, expected.divider, reason: 'divider');
  expectColorEquals(actual.border, expected.border, reason: 'border');
  expectColorEquals(actual.shadow, expected.shadow, reason: 'shadow');
  expectColorEquals(actual.scaleTick, expected.scaleTick, reason: 'scaleTick');
  expectColorEquals(actual.scaleTickAccent, expected.scaleTickAccent, reason: 'scaleTickAccent');
  expectColorEquals(actual.labelDefault, expected.labelDefault, reason: 'labelDefault');
  expectColorEquals(actual.labelMuted, expected.labelMuted, reason: 'labelMuted');
  expectColorEquals(actual.annotationYin, expected.annotationYin, reason: 'annotationYin');
  expectColorEquals(actual.annotationSu, expected.annotationSu, reason: 'annotationSu');
  expectColorEquals(actual.sectorBorder, expected.sectorBorder, reason: 'sectorBorder');
  expectColorEquals(actual.northLine, expected.northLine, reason: 'northLine');
}

void main() {
  late String yamlStr;

  setUpAll(() {
    yamlStr = File('assets/theme/chart_tokens.yaml').readAsStringSync();
  });

  group('ChartTokenLoader', () {
    test('loadFromYamlString produces QiZhengChartStyle matching fallback', () {
      final loaded = ChartTokenLoader.loadFromYamlString(yamlStr);
      final fallback = QiZhengChartStyle.fallback();

      // 颜色逐字段比较（处理 MaterialColor vs Color 类型差异）
      expectSemanticColorsEquals(loaded.colors, fallback.colors);
      expect(loaded.typography, equals(fallback.typography));
      expect(loaded.geometry, equals(fallback.geometry));
      expect(loaded.brightness, equals(Brightness.light));
    });

    test('loadFromYamlString with starPalette produces QiZhengStarPalette matching fallback', () {
      final loaded = ChartStarPaletteLoader.loadFromYamlString(yamlStr);
      final fallback = QiZhengStarPalette.fallback();

      // 逐键比较色板颜色值
      for (final star in loaded.zhengColorMap.keys) {
        expectColorEquals(
          loaded.zhengColor(star),
          fallback.zhengColor(star),
          reason: 'zheng $star mismatch',
        );
      }
      for (final star in loaded.starsColorMap.keys) {
        expectColorEquals(
          loaded.starColor(star),
          fallback.starColor(star),
          reason: 'stars $star mismatch',
        );
      }
    });

    test('parseColor handles #RRGGBB format', () {
      const testYaml = '''
colors:
  ringStroke: "#FF0000"
  divider: "#00FF00"
  border: "#0000FF"
  shadow: "#000000"
  scaleTick: "#FFFFFF"
  scaleTickAccent: "#123456"
  labelDefault: "#ABCDEF"
  labelMuted: "#111111"
  annotationYin: "#222222"
  annotationSu: "#333333"
  sectorBorder: "#444444"
  northLine: "#555555"
typography:
  constellationName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  starName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  gongName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  degree: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  yearMonth: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  shenSha: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
geometry:
  ringStrokeWidth: 1.0
  tickLength: 1.0
  longTickLength: 1.0
  innerPadding: 1.0
  outerPadding: 1.0
  guideDotRadius: 1.0
  starHolderRadius: 1.0
''';
      final style = ChartTokenLoader.loadFromYamlString(testYaml);
      // #FF0000 → 0xFFFF0000 = Colors.red
      expect(style.colors.ringStroke.toARGB32(), equals(0xFFFF0000));
      // #00FF00 → 0xFF00FF00 = Colors.green
      expect(style.colors.divider.toARGB32(), equals(0xFF00FF00));
      // #0000FF → 0xFF0000FF = Colors.blue
      expect(style.colors.border.toARGB32(), equals(0xFF0000FF));
    });

    test('parseColor handles #AARRGGBB format', () {
      const testYaml = '''
colors:
  ringStroke: "#DD000000"
  divider: "#61000000"
  border: "#FF9E9E9E"
  shadow: "#73000000"
  scaleTick: "#1F000000"
  scaleTickAccent: "#00000000"
  labelDefault: "#FFFFFFFF"
  labelMuted: "#80FF0000"
  annotationYin: "#4000FF00"
  annotationSu: "#C00000FF"
  sectorBorder: "#20FFFF00"
  northLine: "#E000FFFF"
typography:
  constellationName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  starName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  gongName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  degree: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  yearMonth: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  shenSha: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
geometry:
  ringStrokeWidth: 1.0
  tickLength: 1.0
  longTickLength: 1.0
  innerPadding: 1.0
  outerPadding: 1.0
  guideDotRadius: 1.0
  starHolderRadius: 1.0
''';
      final style = ChartTokenLoader.loadFromYamlString(testYaml);
      expect(style.colors.ringStroke.toARGB32(), equals(0xDD000000));
      expect(style.colors.divider.toARGB32(), equals(0x61000000));
      expect(style.colors.sectorBorder.toARGB32(), equals(0x20FFFF00));
    });

    test('fontWeight parsing handles all supported values', () {
      const normalYaml = '''
colors:
  ringStroke: "#000000"
  divider: "#000000"
  border: "#000000"
  shadow: "#000000"
  scaleTick: "#000000"
  scaleTickAccent: "#000000"
  labelDefault: "#000000"
  labelMuted: "#000000"
  annotationYin: "#000000"
  annotationSu: "#000000"
  sectorBorder: "#000000"
  northLine: "#000000"
typography:
  constellationName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  starName: {family: Test, fontSize: 10.0, fontWeight: bold, height: 1.0}
  gongName: {family: Test, fontSize: 10.0, fontWeight: w400, height: 1.0}
  degree: {family: Test, fontSize: 10.0, fontWeight: w700, height: 1.0}
  yearMonth: {family: Test, fontSize: 10.0, fontWeight: w100, height: 1.0}
  shenSha: {family: Test, fontSize: 10.0, fontWeight: w900, height: 1.0}
geometry:
  ringStrokeWidth: 1.0
  tickLength: 1.0
  longTickLength: 1.0
  innerPadding: 1.0
  outerPadding: 1.0
  guideDotRadius: 1.0
  starHolderRadius: 1.0
''';
      final style = ChartTokenLoader.loadFromYamlString(normalYaml);
      expect(style.typography.constellationName.fontWeight, equals(FontWeight.w400));
      expect(style.typography.starName.fontWeight, equals(FontWeight.w700));
      expect(style.typography.gongName.fontWeight, equals(FontWeight.w400));
      expect(style.typography.degree.fontWeight, equals(FontWeight.w700));
      expect(style.typography.yearMonth.fontWeight, equals(FontWeight.w100));
      expect(style.typography.shenSha.fontWeight, equals(FontWeight.w900));
    });

    test('missing colors section throws descriptive FormatException', () {
      const badYaml = '''
typography:
  constellationName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  starName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  gongName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  degree: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  yearMonth: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  shenSha: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
geometry:
  ringStrokeWidth: 1.0
  tickLength: 1.0
  longTickLength: 1.0
  innerPadding: 1.0
  outerPadding: 1.0
  guideDotRadius: 1.0
  starHolderRadius: 1.0
''';
      expect(
        () => ChartTokenLoader.loadFromYamlString(badYaml),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('colors'),
        )),
      );
    });

    test('missing typography section throws descriptive FormatException', () {
      const badYaml = '''
colors:
  ringStroke: "#000000"
  divider: "#000000"
  border: "#000000"
  shadow: "#000000"
  scaleTick: "#000000"
  scaleTickAccent: "#000000"
  labelDefault: "#000000"
  labelMuted: "#000000"
  annotationYin: "#000000"
  annotationSu: "#000000"
  sectorBorder: "#000000"
  northLine: "#000000"
geometry:
  ringStrokeWidth: 1.0
  tickLength: 1.0
  longTickLength: 1.0
  innerPadding: 1.0
  outerPadding: 1.0
  guideDotRadius: 1.0
  starHolderRadius: 1.0
''';
      expect(
        () => ChartTokenLoader.loadFromYamlString(badYaml),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('typography'),
        )),
      );
    });

    test('missing geometry section throws descriptive FormatException', () {
      const badYaml = '''
colors:
  ringStroke: "#000000"
  divider: "#000000"
  border: "#000000"
  shadow: "#000000"
  scaleTick: "#000000"
  scaleTickAccent: "#000000"
  labelDefault: "#000000"
  labelMuted: "#000000"
  annotationYin: "#000000"
  annotationSu: "#000000"
  sectorBorder: "#000000"
  northLine: "#000000"
typography:
  constellationName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  starName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  gongName: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  degree: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  yearMonth: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
  shenSha: {family: Test, fontSize: 10.0, fontWeight: normal, height: 1.0}
''';
      expect(
        () => ChartTokenLoader.loadFromYamlString(badYaml),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('geometry'),
        )),
      );
    });

    test('YamlChartStyleResolver.fromYamlString round-trips correctly', () {
      final resolver = YamlChartStyleResolver.fromYamlString(yamlStr);

      final lightStyle = resolver.resolve(Brightness.light);
      final darkStyle = resolver.resolve(Brightness.dark);
      final fallback = QiZhengChartStyle.fallback();

      // light 模式：颜色值应与 fallback 一致（使用值比较而非类型比较）
      expectSemanticColorsEquals(lightStyle.colors, fallback.colors);
      expect(lightStyle.typography, equals(fallback.typography));
      expect(lightStyle.geometry, equals(fallback.geometry));
      expect(lightStyle.brightness, equals(Brightness.light));

      // dark 模式：颜色值应与 fallback 一致，亮度为 dark
      expectSemanticColorsEquals(darkStyle.colors, fallback.colors);
      expect(darkStyle.brightness, equals(Brightness.dark));

      // 色板解析正确
      final palette = resolver.resolvePalette(Brightness.light);
      for (final star in palette.zhengColorMap.keys) {
        expectColorEquals(
          palette.zhengColor(star),
          QiZhengStarPalette.fallback().zhengColor(star),
          reason: 'resolver palette zheng $star mismatch',
        );
      }
    });
  });
}
