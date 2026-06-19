import 'package:flutter/widgets.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:theme/theme.dart';

import 'chart_style_resolver.dart';
import 'qi_zheng_chart_style.dart';
import 'qi_zheng_star_palette.dart';
import 'token_loader.dart';

/// Bridges the unified theme pipeline ([XuanThemeData].chartTokens) to
/// [QiZhengChartStyle] and [QiZhengStarPalette].
///
/// Reads [ChartThemeTokens] from [XuanThemeScope] (via [BuildContext]) or
/// from pre-parsed tokens (for testing / no-context usage).
/// Falls back to [FallbackChartStyleResolver] when no scope or tokens.
class ThemeChartStyleResolver implements ChartStyleResolver {
  final BuildContext? _context;
  final ChartThemeTokens? _tokensOverride;

  /// Creates a resolver bound to a [BuildContext] for [XuanThemeScope] access.
  const ThemeChartStyleResolver(BuildContext context)
      : _context = context,
        _tokensOverride = null;

  /// Creates a resolver from pre-parsed tokens (for testing / no-context usage).
  const ThemeChartStyleResolver.fromTokens(ChartThemeTokens tokens)
      : _tokensOverride = tokens,
        _context = null;

  ChartThemeTokens? _resolveTokens() {
    if (_tokensOverride != null) return _tokensOverride;
    if (_context == null) return null;
    final themeData = XuanThemeData.maybeOf(_context);
    return themeData?.chartTokens;
  }

  @override
  QiZhengChartStyle resolve(Brightness brightness) {
    final tokens = _resolveTokens();
    if (tokens == null || tokens == ChartThemeTokens.empty) {
      return QiZhengChartStyle.fallback(brightness: brightness);
    }
    return _parseChartStyle(tokens, brightness);
  }

  @override
  QiZhengStarPalette resolvePalette(Brightness brightness) {
    final tokens = _resolveTokens();
    if (tokens == null || tokens == ChartThemeTokens.empty) {
      return QiZhengStarPalette.fallback(brightness: brightness);
    }
    return _parseStarPalette(tokens);
  }

  static QiZhengChartStyle _parseChartStyle(
      ChartThemeTokens tokens, Brightness brightness) {
    final colorsMap = tokens.colors;
    final typographyMap = tokens.typography;
    final geometryMap = tokens.geometry;

    final colors = ChartSemanticColors(
      ringStroke:
          TokenLoader.parseColor(colorsMap['ringStroke']) ?? const Color(0xFF000000),
      divider:
          TokenLoader.parseColor(colorsMap['divider']) ?? const Color(0xDD000000),
      border:
          TokenLoader.parseColor(colorsMap['border']) ?? const Color(0xFF9E9E9E),
      shadow:
          TokenLoader.parseColor(colorsMap['shadow']) ?? const Color(0x61000000),
      scaleTick:
          TokenLoader.parseColor(colorsMap['scaleTick']) ?? const Color(0xDD000000),
      scaleTickAccent:
          TokenLoader.parseColor(colorsMap['scaleTickAccent']) ?? const Color(0xFF448AFF),
      labelDefault:
          TokenLoader.parseColor(colorsMap['labelDefault']) ?? const Color(0xFF000000),
      labelMuted:
          TokenLoader.parseColor(colorsMap['labelMuted']) ?? const Color(0x73000000),
      annotationYin:
          TokenLoader.parseColor(colorsMap['annotationYin']) ?? const Color(0x73000000),
      annotationSu:
          TokenLoader.parseColor(colorsMap['annotationSu']) ?? const Color(0xFFF44336),
      sectorBorder:
          TokenLoader.parseColor(colorsMap['sectorBorder']) ?? const Color(0x1F000000),
      northLine:
          TokenLoader.parseColor(colorsMap['northLine']) ?? const Color(0xFFF44336),
    );

    ChartTypographyRole parseRole(String key) {
      final m = typographyMap[key];
      if (m is! Map) {
        return ChartTypography.fallback().constellationName; // safe fallback
      }
      return ChartTypographyRole(
        family: m['family']?.toString() ?? 'NotoSansSC',
        fontSize: (m['fontSize'] as num?)?.toDouble() ?? 14.0,
        fontWeight: TokenLoader.parseFontWeight(m['fontWeight']),
        height: (m['height'] as num?)?.toDouble() ?? 1.0,
      );
    }

    final typography = ChartTypography(
      constellationName: parseRole('constellationName'),
      starName: parseRole('starName'),
      gongName: parseRole('gongName'),
      degree: parseRole('degree'),
      yearMonth: parseRole('yearMonth'),
      shenSha: parseRole('shenSha'),
    );

    double parseGeom(String key, double fallback) {
      final v = geometryMap[key];
      return (v as num?)?.toDouble() ?? fallback;
    }

    final geometry = ChartGeometry(
      ringStrokeWidth: parseGeom('ringStrokeWidth', 0.5),
      tickLength: parseGeom('tickLength', 5.0),
      longTickLength: parseGeom('longTickLength', 10.0),
      innerPadding: parseGeom('innerPadding', 12.0),
      outerPadding: parseGeom('outerPadding', 12.0),
      guideDotRadius: parseGeom('guideDotRadius', 2.0),
      starHolderRadius: parseGeom('starHolderRadius', 6.0),
    );

    return QiZhengChartStyle(
      colors: colors,
      typography: typography,
      geometry: geometry,
      brightness: brightness,
    );
  }

  static QiZhengStarPalette _parseStarPalette(ChartThemeTokens tokens) {
    final paletteMap = tokens.starPalette;

    Map<EnumStars, Color> parseColorMap(dynamic raw) {
      if (raw is! Map) return {};
      final result = <EnumStars, Color>{};
      for (final entry in raw.entries) {
        final starName = entry.key.toString();
        final star = _starFromName(starName);
        if (star == null) continue; // skip unknown stars
        final color = TokenLoader.parseColor(entry.value);
        if (color != null) {
          result[star] = color;
        }
      }
      return result;
    }

    return QiZhengStarPalette(
      zhengColorMap: parseColorMap(paletteMap['zheng']),
      starsColorMap: parseColorMap(paletteMap['stars']),
    );
  }

  /// Maps YAML star name strings to [EnumStars] enum values.
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
