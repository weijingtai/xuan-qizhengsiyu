/// 竹罗三限 → SpiralSeriesSpec 映射层 (Doc B §3.1, Q6)
///
/// 将 ZhuLuoYearResult 逐年结构映射成 SpiralSeriesSpec，
/// 含 styleKey 命名表与 marker。
///
/// 注意：这些类型定义应与 metaphysics-chart-ui 的契约对齐。
/// 当 T1 契约在 period_spiral.dart 中实现后，替换为导入。
library;

import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'zhu_luo_san_xian_calculator.dart';
import 'zhu_luo_san_xian_tables.dart';

/// 一条限程螺旋的完整绘制描述 (契约 SSOT)
class SpiralSeriesSpec {
  final String id;
  final double startAngleDeg;
  final double innerRadius;
  final double outerRadius;
  final List<SpiralSegment> segments;
  final List<SpiralMarker> markers;

  const SpiralSeriesSpec({
    required this.id,
    required this.startAngleDeg,
    required this.innerRadius,
    required this.outerRadius,
    required this.segments,
    required this.markers,
  });
}

/// 一段 = 螺旋上的一个格子
class SpiralSegment {
  final double sweepDeg;
  final String label;
  final String styleKey;

  const SpiralSegment({
    required this.sweepDeg,
    required this.label,
    required this.styleKey,
  });
}

/// 交限标线等抽象标记
class SpiralMarker {
  final int afterSegmentIndex;
  final String label;
  final String styleKey;

  const SpiralMarker({
    required this.afterSegmentIndex,
    required this.label,
    required this.styleKey,
  });
}

/// styleKey 常量 (Doc B §9)
const String kStyleKeyBenGong = 'zhuluo.benGong';
const String kStyleKeyLingNian = 'zhuluo.lingNian';
const String kStyleKeyYanJiao = 'zhuluo.yanJiao';
const String kStyleKeyBuQiao = 'zhuluo.buQiao';
const String kStyleKeyZheFan = 'zhuluo.zheFan';
const String kStyleKeyForcedCut = 'zhuluo.forcedCut';
const String kStyleKeyTransition = 'zhuluo.transition';

/// 宫位索引到角度的映射
/// 约定：0°=正上、顺时针为正，第 p 宫扇区 = [p*30-30, p*30)
double _palaceToStartAngle(EnumTwelveGong palace) {
  return (palace.index * 30 - 30 + 360) % 360;
}

/// 将 ZhuLuoYearResult 列表映射成 SpiralSeriesSpec
/// 
/// [results] - 单限的逐年结果
/// [limitId] - 限的标识 (如 'limit-0', 'limit-1', 'limit-2')
/// [innerRadius] - 环带内沿
/// [outerRadius] - 环带外沿
/// [nextRulerName] - 下一限主星名（用于交限标记）
SpiralSeriesSpec mapToSpiralSeriesSpec({
  required List<ZhuLuoYearResult> results,
  required String limitId,
  required double innerRadius,
  required double outerRadius,
  String? nextRulerName,
}) {
  if (results.isEmpty) {
    return SpiralSeriesSpec(
      id: limitId,
      startAngleDeg: 0,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      segments: [],
      markers: [],
    );
  }

  final segments = <SpiralSegment>[];
  final markers = <SpiralMarker>[];
  
  EnumTwelveGong? lastPalace;
  var consecutiveCount = 0;

  for (var i = 0; i < results.length; i++) {
    final result = results[i];
    final currentPalace = result.palace;
    
    // 计算 sweepDeg
    double sweepDeg;
    String styleKey;
    
    if (result.phase == "hold") {
      // 本宫静守：等分本宫为 N 段
      sweepDeg = 30.0 / rulerNumber(result.ruler);
      styleKey = kStyleKeyBenGong;
    } else if (result.phase == "direct") {
      // 标准顺行：每年一宫 30°
      sweepDeg = 30.0;
      styleKey = kStyleKeyLingNian;
    } else if (result.phase == "yanJiao") {
      // 延交尾段（方案1/3）
      sweepDeg = 30.0;
      styleKey = kStyleKeyYanJiao;
    } else if (result.phase == "buQiao") {
      // 补桥段（方案4）
      sweepDeg = 30.0 / rulerNumber(result.ruler);
      styleKey = kStyleKeyBuQiao;
    } else if (result.phase == "zheFan") {
      // 折返段（方案3，负向）
      sweepDeg = -30.0;
      styleKey = kStyleKeyZheFan;
    } else if (result.phase == "forcedCut") {
      // 强制截断标记（方案2/4兜底）
      sweepDeg = 0;
      styleKey = kStyleKeyForcedCut;
    } else {
      sweepDeg = 30.0;
      styleKey = kStyleKeyLingNian;
    }

    // 如果是新宫位的开始，添加分段
    if (currentPalace != lastPalace) {
      if (consecutiveCount > 0 && lastPalace != null) {
        // 结束上一段连续宫位
      }
      consecutiveCount = 1;
      lastPalace = currentPalace;
    } else {
      consecutiveCount++;
    }

    segments.add(SpiralSegment(
      sweepDeg: sweepDeg,
      label: '${result.age}',
      styleKey: styleKey,
    ));

    // 检查是否是交限年
    if (result.isTransitionYear && i < results.length - 1) {
      markers.add(SpiralMarker(
        afterSegmentIndex: i,
        label: nextRulerName ?? '',
        styleKey: kStyleKeyTransition,
      ));
    }
  }

  // 计算起始角度（第一段的起始角）
  final startAngleDeg = _palaceToStartAngle(results.first.palace);

  return SpiralSeriesSpec(
    id: limitId,
    startAngleDeg: startAngleDeg,
    innerRadius: innerRadius,
    outerRadius: outerRadius,
    segments: segments,
    markers: markers,
  );
}

/// 将三限结果映射成三条 SpiralSeriesSpec
/// 
/// [firstResults] - 初限逐年结果
/// [middleResults] - 中限逐年结果
/// [lastResults] - 末限逐年结果
/// [firstRadius] - 初限环带 [内沿, 外沿]
/// [middleRadius] - 中限环带 [内沿, 外沿]
/// [lastRadius] - 末限环带 [内沿, 外沿]
List<SpiralSeriesSpec> mapThreeLimitsToSpiralSeries({
  required List<ZhuLuoYearResult> firstResults,
  required List<ZhuLuoYearResult> middleResults,
  required List<ZhuLuoYearResult> lastResults,
  required (double, double) firstRadius,
  required (double, double) middleRadius,
  required (double, double) lastRadius,
  ZhuLuoRuler? middleRuler,
  ZhuLuoRuler? lastRuler,
}) {
  return [
    mapToSpiralSeriesSpec(
      results: firstResults,
      limitId: 'limit-0',
      innerRadius: firstRadius.$1,
      outerRadius: firstRadius.$2,
      nextRulerName: middleRuler?.name,
    ),
    mapToSpiralSeriesSpec(
      results: middleResults,
      limitId: 'limit-1',
      innerRadius: middleRadius.$1,
      outerRadius: middleRadius.$2,
      nextRulerName: lastRuler?.name,
    ),
    mapToSpiralSeriesSpec(
      results: lastResults,
      limitId: 'limit-2',
      innerRadius: lastRadius.$1,
      outerRadius: lastRadius.$2,
    ),
  ];
}
