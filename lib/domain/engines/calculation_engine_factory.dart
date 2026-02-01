import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';

import 'historical_engine.dart';
import 'i_calculation_engine.dart';
import 'sweph_engine.dart';

/// 引擎工厂，用于根据指定的排盘体系类型创建对应的计算引擎实例。
class CalculationEngineFactory {
  /// 根据 [config] 创建并返回一个 [ICalculationEngine] 实例。
  static ICalculationEngine create(BasePanelConfig config) {
    // 根据天体坐标系来决定使用哪个引擎
    if (config.celestialCoordinateSystem ==
        CelestialCoordinateSystem.skyEquatorial) {
      // 如果是“天赤道制”，则使用历史引擎
      return HistoricalEngine();
    } else {
      // 其他所有情况（如黄道制、赤道制）都使用基于SWEPH的现代引擎
      return SwephEngine();
    }
  }
}
