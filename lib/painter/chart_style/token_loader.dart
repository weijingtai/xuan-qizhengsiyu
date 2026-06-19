import 'dart:ui';

import 'package:yaml/yaml.dart';
import 'package:metaphysics_core/enums.dart';

import 'qi_zheng_chart_style.dart';
import 'qi_zheng_star_palette.dart';

/// 十四政图表令牌加载器
/// 从 YAML 字符串解析 [QiZhengChartStyle]。
class ChartTokenLoader {
  ChartTokenLoader._();

  /// 从 YAML 字符串加载 [QiZhengChartStyle]。
  ///
  /// YAML 必须包含 `colors`、`typography`、`geometry` 三个顶级键。
  /// 缺少任何必需键时抛出 [FormatException]。
  static QiZhengChartStyle loadFromYamlString(String yamlStr) {
    final doc = loadYaml(yamlStr);

    if (doc is! YamlMap) {
      throw const FormatException('YAML document must be a map');
    }

    final colors = _parseSemanticColors(doc);
    final typography = _parseTypography(doc);
    final geometry = _parseGeometry(doc);
    final brightness = _parseBrightness(doc);

    return QiZhengChartStyle(
      colors: colors,
      typography: typography,
      geometry: geometry,
      brightness: brightness,
    );
  }

  // ── 语义颜色解析 ──────────────────────────────────────────────────

  static ChartSemanticColors _parseSemanticColors(YamlMap doc) {
    final colorsMap = doc['colors'];
    if (colorsMap is! YamlMap) {
      throw const FormatException("Missing or invalid 'colors' section");
    }

    return ChartSemanticColors(
      ringStroke: _requireColor(colorsMap, 'ringStroke'),
      divider: _requireColor(colorsMap, 'divider'),
      border: _requireColor(colorsMap, 'border'),
      shadow: _requireColor(colorsMap, 'shadow'),
      scaleTick: _requireColor(colorsMap, 'scaleTick'),
      scaleTickAccent: _requireColor(colorsMap, 'scaleTickAccent'),
      labelDefault: _requireColor(colorsMap, 'labelDefault'),
      labelMuted: _requireColor(colorsMap, 'labelMuted'),
      annotationYin: _requireColor(colorsMap, 'annotationYin'),
      annotationSu: _requireColor(colorsMap, 'annotationSu'),
      sectorBorder: _requireColor(colorsMap, 'sectorBorder'),
      northLine: _requireColor(colorsMap, 'northLine'),
    );
  }

  // ── 排版解析 ─────────────────────────────────────────────────────

  static ChartTypography _parseTypography(YamlMap doc) {
    final typoMap = doc['typography'];
    if (typoMap is! YamlMap) {
      throw const FormatException("Missing or invalid 'typography' section");
    }

    return ChartTypography(
      constellationName: _parseTypographyRole(typoMap, 'constellationName'),
      starName: _parseTypographyRole(typoMap, 'starName'),
      gongName: _parseTypographyRole(typoMap, 'gongName'),
      degree: _parseTypographyRole(typoMap, 'degree'),
      yearMonth: _parseTypographyRole(typoMap, 'yearMonth'),
      shenSha: _parseTypographyRole(typoMap, 'shenSha'),
    );
  }

  static ChartTypographyRole _parseTypographyRole(YamlMap parent, String key) {
    final roleMap = parent[key];
    if (roleMap is! YamlMap) {
      throw FormatException("Missing or invalid typography role '$key'");
    }

    final family = roleMap['family'];
    if (family is! String) {
      throw FormatException("Missing 'family' in typography role '$key'");
    }

    final fontSize = roleMap['fontSize'];
    if (fontSize is! num) {
      throw FormatException("Missing 'fontSize' in typography role '$key'");
    }

    final fontWeightStr = roleMap['fontWeight'];
    if (fontWeightStr is! String) {
      throw FormatException("Missing 'fontWeight' in typography role '$key'");
    }

    final height = roleMap['height'];
    if (height is! num) {
      throw FormatException("Missing 'height' in typography role '$key'");
    }

    return ChartTypographyRole(
      family: family,
      fontSize: fontSize.toDouble(),
      fontWeight: _parseFontWeight(fontWeightStr),
      height: height.toDouble(),
    );
  }

  // ── 几何尺寸解析 ─────────────────────────────────────────────────

  static ChartGeometry _parseGeometry(YamlMap doc) {
    final geoMap = doc['geometry'];
    if (geoMap is! YamlMap) {
      throw const FormatException("Missing or invalid 'geometry' section");
    }

    return ChartGeometry(
      ringStrokeWidth: _requireDouble(geoMap, 'ringStrokeWidth'),
      tickLength: _requireDouble(geoMap, 'tickLength'),
      longTickLength: _requireDouble(geoMap, 'longTickLength'),
      innerPadding: _requireDouble(geoMap, 'innerPadding'),
      outerPadding: _requireDouble(geoMap, 'outerPadding'),
      guideDotRadius: _requireDouble(geoMap, 'guideDotRadius'),
      starHolderRadius: _requireDouble(geoMap, 'starHolderRadius'),
    );
  }

  // ── 亮度解析 ─────────────────────────────────────────────────────

  static Brightness _parseBrightness(YamlMap doc) {
    final b = doc['brightness'];
    if (b is! String) return Brightness.light;
    return b == 'dark' ? Brightness.dark : Brightness.light;
  }

  // ── 通用辅助方法 ─────────────────────────────────────────────────

  static Color _requireColor(YamlMap map, String key) {
    final value = map[key];
    if (value is! String) {
      throw FormatException("Missing or invalid color value for '$key'");
    }
    return _parseColor(value);
  }

  static double _requireDouble(YamlMap map, String key) {
    final value = map[key];
    if (value is! num) {
      throw FormatException("Missing or invalid numeric value for '$key'");
    }
    return value.toDouble();
  }
}

/// 十四政星曜色板加载器
/// 从 YAML 字符串解析 [QiZhengStarPalette]。
class ChartStarPaletteLoader {
  ChartStarPaletteLoader._();

  /// 从 YAML 字符串加载 [QiZhengStarPalette]。
  ///
  /// YAML 必须包含 `starPalette.zheng` 和 `starPalette.stars` 两个子键。
  static QiZhengStarPalette loadFromYamlString(String yamlStr) {
    final doc = loadYaml(yamlStr);

    if (doc is! YamlMap) {
      throw const FormatException('YAML document must be a map');
    }

    final paletteMap = doc['starPalette'];
    if (paletteMap is! YamlMap) {
      throw const FormatException("Missing or invalid 'starPalette' section");
    }

    final zhengMap = paletteMap['zheng'];
    if (zhengMap is! YamlMap) {
      throw const FormatException("Missing or invalid 'starPalette.zheng'");
    }

    final starsMap = paletteMap['stars'];
    if (starsMap is! YamlMap) {
      throw const FormatException("Missing or invalid 'starPalette.stars'");
    }

    return QiZhengStarPalette(
      zhengColorMap: _parseStarColorMap(zhengMap),
      starsColorMap: _parseStarColorMap(starsMap),
    );
  }

  static Map<EnumStars, Color> _parseStarColorMap(YamlMap map) {
    final result = <EnumStars, Color>{};
    for (final entry in map.entries) {
      final starName = entry.key.toString();
      final star = _starFromName(starName);
      if (star == null) {
        throw FormatException("Unknown star name: '$starName'");
      }
      if (entry.value is! String) {
        throw FormatException("Invalid color value for star '$starName'");
      }
      result[star] = _parseColor(entry.value as String);
    }
    return result;
  }

  /// 将 YAML 中的星曜名称映射到 [EnumStars] 枚举值。
  static EnumStars? _starFromName(String name) {
    return switch (name) {
      'Sun' => EnumStars.Sun,
      'Moon' => EnumStars.Moon,
      'Mercury' => EnumStars.Mercury,
      'Mars' => EnumStars.Mars,
      'Saturn' => EnumStars.Saturn,
      'Venus' => EnumStars.Venus,
      'Jupiter' => EnumStars.Jupiter,
      'Qi' => EnumStars.Qi,
      'Luo' => EnumStars.Luo,
      'Ji' => EnumStars.Ji,
      'Bei' => EnumStars.Bei,
      _ => null,
    };
  }
}

// ── 私有辅助函数 ─────────────────────────────────────────────────────

/// 解析十六进制颜色字符串为 [Color]。
///
/// 支持格式:
/// - `#RRGGBB` (6位，完全不透明，alpha = 0xFF)
/// - `#AARRGGBB` (8位，含 alpha 通道)
Color _parseColor(String hex) {
  var h = hex.startsWith('#') ? hex.substring(1) : hex;
  if (h.length == 6) {
    h = 'FF$h'; // 默认完全不透明
  } else if (h.length != 8) {
    throw FormatException('Invalid hex color format: $hex');
  }
  final value = int.tryParse(h, radix: 16);
  if (value == null) {
    throw FormatException('Invalid hex color value: $hex');
  }
  return Color(value);
}

/// 解析字重字符串为 [FontWeight]。
///
/// 映射规则:
/// - `normal` → [FontWeight.w400]
/// - `bold` → [FontWeight.w700]
/// - `w100` ~ `w900` → 对应 [FontWeight]
FontWeight _parseFontWeight(String value) {
  return switch (value) {
    'normal' => FontWeight.w400,
    'bold' => FontWeight.w700,
    'w100' => FontWeight.w100,
    'w200' => FontWeight.w200,
    'w300' => FontWeight.w300,
    'w400' => FontWeight.w400,
    'w500' => FontWeight.w500,
    'w600' => FontWeight.w600,
    'w700' => FontWeight.w700,
    'w800' => FontWeight.w800,
    'w900' => FontWeight.w900,
    _ => throw FormatException('Unknown fontWeight value: $value'),
  };
}
