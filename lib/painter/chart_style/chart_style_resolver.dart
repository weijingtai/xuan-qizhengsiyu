import 'dart:ui';

import 'qi_zheng_chart_style.dart';
import 'qi_zheng_star_palette.dart';

abstract class ChartStyleResolver {
  QiZhengChartStyle resolve(Brightness brightness);
  QiZhengStarPalette resolvePalette(Brightness brightness);
}

class FallbackChartStyleResolver implements ChartStyleResolver {
  const FallbackChartStyleResolver();

  @override
  QiZhengChartStyle resolve(Brightness brightness) {
    return QiZhengChartStyle.fallback(brightness: brightness);
  }

  @override
  QiZhengStarPalette resolvePalette(Brightness brightness) {
    return QiZhengStarPalette.fallback(brightness: brightness);
  }
}
