// ignore_for_file: deprecated_member_use_from_same_package
// This file deliberately tests deprecated ChartTokenLoader for parity checks.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
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
  late YamlMap yamlDoc;

  setUpAll(() {
    yamlStr = File('assets/theme/chart_tokens.yaml').readAsStringSync();
    yamlDoc = loadYaml(yamlStr) as YamlMap;
  });

  group('Token Governance', () {
    test('audit: scan painter files for ?? Colors.xxx fallback patterns', () {
      // 扫描 lib/painter/ 目录下所有 .dart 文件，记录 ?? Colors.xxx 模式
      final painterDir = Directory('lib/painter');
      final fallbackPattern = RegExp(r'\?\?\s*Colors\.\w+');
      final findings = <String>[];

      if (painterDir.existsSync()) {
        for (final entity in painterDir.listSync(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            final content = entity.readAsStringSync();
            final matches = fallbackPattern.allMatches(content);
            for (final match in matches) {
              findings.add('${entity.path}: ${match.group(0)}');
            }
          }
        }
      }

      // 审计模式：记录但不失败
      if (findings.isNotEmpty) {
        debugPrint('⚠ Found ${findings.length} ?? Colors.xxx fallback patterns:');
        for (final f in findings) {
          debugPrint('  - $f');
        }
      }
      // 仅验证扫描完成，不强制为空
      expect(findings, isA<List<String>>());
    });

    test('YAML file has all required keys (completeness)', () {
      // 验证顶级键
      expect(yamlDoc.containsKey('version'), isTrue, reason: 'Missing top-level key: version');
      expect(yamlDoc.containsKey('brightness'), isTrue, reason: 'Missing top-level key: brightness');
      expect(yamlDoc.containsKey('colors'), isTrue, reason: 'Missing top-level key: colors');
      expect(yamlDoc.containsKey('typography'), isTrue, reason: 'Missing top-level key: typography');
      expect(yamlDoc.containsKey('geometry'), isTrue, reason: 'Missing top-level key: geometry');
      expect(yamlDoc.containsKey('starPalette'), isTrue, reason: 'Missing top-level key: starPalette');

      // 验证 colors 子键
      final colors = yamlDoc['colors'] as YamlMap;
      const requiredColorKeys = [
        'ringStroke', 'divider', 'border', 'shadow',
        'scaleTick', 'scaleTickAccent', 'labelDefault', 'labelMuted',
        'annotationYin', 'annotationSu', 'sectorBorder', 'northLine',
      ];
      for (final key in requiredColorKeys) {
        expect(colors.containsKey(key), isTrue, reason: 'Missing color key: $key');
      }

      // 验证 typography 子键
      final typo = yamlDoc['typography'] as YamlMap;
      const requiredTypoKeys = [
        'constellationName', 'starName', 'gongName',
        'degree', 'yearMonth', 'shenSha',
      ];
      for (final key in requiredTypoKeys) {
        expect(typo.containsKey(key), isTrue, reason: 'Missing typography key: $key');
        final role = typo[key] as YamlMap;
        expect(role.containsKey('family'), isTrue, reason: 'Missing family in $key');
        expect(role.containsKey('fontSize'), isTrue, reason: 'Missing fontSize in $key');
        expect(role.containsKey('fontWeight'), isTrue, reason: 'Missing fontWeight in $key');
        expect(role.containsKey('height'), isTrue, reason: 'Missing height in $key');
      }

      // 验证 geometry 子键
      final geo = yamlDoc['geometry'] as YamlMap;
      const requiredGeoKeys = [
        'ringStrokeWidth', 'tickLength', 'longTickLength',
        'innerPadding', 'outerPadding', 'guideDotRadius', 'starHolderRadius',
      ];
      for (final key in requiredGeoKeys) {
        expect(geo.containsKey(key), isTrue, reason: 'Missing geometry key: $key');
      }

      // 验证 starPalette 子键
      final palette = yamlDoc['starPalette'] as YamlMap;
      expect(palette.containsKey('zheng'), isTrue, reason: 'Missing starPalette.zheng');
      expect(palette.containsKey('stars'), isTrue, reason: 'Missing starPalette.stars');

      final zheng = palette['zheng'] as YamlMap;
      const requiredZhengKeys = ['Sun', 'Moon', 'Mars', 'Saturn', 'Mercury', 'Jupiter', 'Venus'];
      for (final key in requiredZhengKeys) {
        expect(zheng.containsKey(key), isTrue, reason: 'Missing zheng star: $key');
      }

      final stars = palette['stars'] as YamlMap;
      const requiredStarsKeys = [
        'Sun', 'Moon', 'Mars', 'Saturn', 'Mercury', 'Jupiter', 'Venus',
        'Qi', 'Bei', 'Ji', 'Luo',
      ];
      for (final key in requiredStarsKeys) {
        expect(stars.containsKey(key), isTrue, reason: 'Missing star: $key');
      }
    });

    test('YAML token values match ChartSemanticColors.fallback() exactly', () {
      final loaded = ChartTokenLoader.loadFromYamlString(yamlStr);
      final fallback = ChartSemanticColors.fallback();

      // 使用值比较而非类型比较（处理 MaterialColor vs Color）
      expectSemanticColorsEquals(loaded.colors, fallback);
    });

    test('YAML token values match ChartTypography.fallback() exactly', () {
      final loaded = ChartTokenLoader.loadFromYamlString(yamlStr);
      final fallback = ChartTypography.fallback();

      expect(loaded.typography.constellationName, equals(fallback.constellationName),
          reason: 'constellationName mismatch');
      expect(loaded.typography.starName, equals(fallback.starName),
          reason: 'starName mismatch');
      expect(loaded.typography.gongName, equals(fallback.gongName),
          reason: 'gongName mismatch');
      expect(loaded.typography.degree, equals(fallback.degree),
          reason: 'degree mismatch');
      expect(loaded.typography.yearMonth, equals(fallback.yearMonth),
          reason: 'yearMonth mismatch');
      expect(loaded.typography.shenSha, equals(fallback.shenSha),
          reason: 'shenSha mismatch');
    });

    test('YAML token values match ChartGeometry.fallback() exactly', () {
      final loaded = ChartTokenLoader.loadFromYamlString(yamlStr);
      final fallback = ChartGeometry.fallback();

      expect(loaded.geometry.ringStrokeWidth, equals(fallback.ringStrokeWidth),
          reason: 'ringStrokeWidth mismatch');
      expect(loaded.geometry.tickLength, equals(fallback.tickLength),
          reason: 'tickLength mismatch');
      expect(loaded.geometry.longTickLength, equals(fallback.longTickLength),
          reason: 'longTickLength mismatch');
      expect(loaded.geometry.innerPadding, equals(fallback.innerPadding),
          reason: 'innerPadding mismatch');
      expect(loaded.geometry.outerPadding, equals(fallback.outerPadding),
          reason: 'outerPadding mismatch');
      expect(loaded.geometry.guideDotRadius, equals(fallback.guideDotRadius),
          reason: 'guideDotRadius mismatch');
      expect(loaded.geometry.starHolderRadius, equals(fallback.starHolderRadius),
          reason: 'starHolderRadius mismatch');
    });
  });
}
