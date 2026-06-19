import 'dart:ui';

import 'chart_style_resolver.dart';
import 'qi_zheng_chart_style.dart';
import 'qi_zheng_star_palette.dart';
import 'token_loader.dart';

/// 基于 YAML 令牌的图表样式解析器
///
/// 实现 [ChartStyleResolver]，从预解析的 [QiZhengChartStyle] 和
/// [QiZhengStarPalette] 提供图表样式。
///
/// 当前实现：light/dark 两种亮度返回同一套样式。
/// 后续可扩展为支持深色主题的 YAML 令牌。
class YamlChartStyleResolver implements ChartStyleResolver {
  final QiZhengChartStyle _style;
  final QiZhengStarPalette _palette;

  const YamlChartStyleResolver({
    required QiZhengChartStyle style,
    required QiZhengStarPalette palette,
  })  : _style = style,
        _palette = palette;

  /// 从 YAML 字符串构造解析器。
  ///
  /// 一次性解析 YAML 中的样式和色板令牌。
  factory YamlChartStyleResolver.fromYamlString(String yamlStr) {
    return YamlChartStyleResolver(
      style: ChartTokenLoader.loadFromYamlString(yamlStr),
      palette: ChartStarPaletteLoader.loadFromYamlString(yamlStr),
    );
  }

  @override
  QiZhengChartStyle resolve(Brightness brightness) {
    // 当前不区分亮度，返回同一套样式
    return _style.copyWith(brightness: brightness);
  }

  @override
  QiZhengStarPalette resolvePalette(Brightness brightness) {
    // 当前不区分亮度，返回同一套色板
    return _palette;
  }
}
