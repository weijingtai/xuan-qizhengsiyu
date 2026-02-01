import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';

import '../entities/models/panel_config.dart';

/// 计算引擎的抽象接口，定义了所有排盘引擎（无论是现代的还是古代的）必须提供的功能。
abstract class ICalculationEngine {
  /// 获取该引擎所使用的坐标系定义
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config);

  /// 计算所有星体的天宫度数
  ///
  /// @param birthDate 出生日期和时间
  /// @param position 观察者位置（经纬度）
  /// @return 一个包含所有星体原生位置的列表
  Future<List<StarPositionRawData>> calculateStarPositions(
      DateTime birthDate, ObserverPosition position, BasePanelConfig config);
}
