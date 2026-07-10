import 'dart:math';

import 'package:metaphysics_core/enums.dart';

import '../entities/models/naming_degree_pair.dart';
import '../entities/models/zhou_tian_model.dart';

/// 周天对齐点拖拽校准 · ②层 七政四余语义适配层。
///
/// 职责：把①层（`ring_drag_angle_delta`）产出的角度增量（弧度，带符号）翻译成
/// “当前指向第几宿第几度” —— 一个 [ConstellationDegree] **绝对值**。
///
/// 读 [ZhouTianModel.starInnOrder]（二十八宿环序）与 [ZhouTianModel.starInnDegreeSeq]
/// （逐宿宽度），把二十八宿环展开成一维“环内坐标”（度），再做角度增量换算。
///
/// 依赖 `ZhouTianModel`/`Enum28Constellations`，是留在本模块的胶水层；
/// 迁移到 chart-ui 后，chart-ui 只需调用本层暴露的“角度→宿度”转换接口。
///
/// 方向约定：**正角度增量 = 对齐点沿 [ZhouTianModel.starInnOrder] 正向前进**
/// （环内坐标增大）。UI 层（③层）按手势朝向决定是否翻转符号，本层只负责数值换算。

/// 二十八宿环总宽度（= 各宿宽度之和，度）。
///
/// 用它而非 `totalDegree` 作换算基准：环视觉上占满整圆（2π），
/// 且逐宿宽度之和才能保证整圈旋转精确回到原点。
double _ringSpan(ZhouTianModel model) =>
    model.starInnDegreeSeq.fold(0.0, (sum, cd) => sum + cd.degree);

/// 逐宿宽度按星宿建索引（与 `ZhouTianCalculator` 一致，顺序无关）。
Map<Enum28Constellations, double> _widthsByConstellation(ZhouTianModel model) => {
      for (final cd in model.starInnDegreeSeq) cd.constellation: cd.degree,
    };

/// 把“宿+度数”绝对值换算成二十八宿环内一维坐标（度，[0, ringSpan)）。
///
/// 坐标从 `starInnOrder.first` 的起点算起，沿环序累加各宿宽度。
double constellationDegreeToRingCoordinate(
  ZhouTianModel model,
  ConstellationDegree point,
) {
  final widths = _widthsByConstellation(model);
  double acc = 0.0;
  for (final constellation in model.starInnOrder) {
    final width = widths[constellation];
    if (width == null) {
      throw ArgumentError(
          'starInnDegreeSeq 中未找到星宿 ${constellation.name} 的宽度数据。');
    }
    if (constellation == point.constellation) {
      return acc + point.degree;
    }
    acc += width;
  }
  throw ArgumentError('对齐星宿 ${point.constellation.name} 不在 starInnOrder 中。');
}

/// 把二十八宿环内一维坐标（度）换算回“宿+度数”绝对值。
///
/// 坐标先按 ringSpan 归一化到 [0, ringSpan)（支持负值/超一圈）。
/// 区间取左闭右开 [start, start+width)，故落在宿边界的坐标归入**下一宿的 0°**。
ConstellationDegree ringCoordinateToConstellationDegree(
  ZhouTianModel model,
  double coordinate,
) {
  final span = _ringSpan(model);
  if (span <= 0) {
    throw ArgumentError('二十八宿环总宽度必须为正，当前为 $span。');
  }

  double coord = coordinate % span;
  if (coord < 0) coord += span;

  final widths = _widthsByConstellation(model);
  final order = model.starInnOrder;
  double acc = 0.0;
  for (int i = 0; i < order.length; i++) {
    final constellation = order[i];
    final width = widths[constellation];
    if (width == null) {
      throw ArgumentError(
          'starInnDegreeSeq 中未找到星宿 ${constellation.name} 的宽度数据。');
    }
    final isLast = i == order.length - 1;
    // 用微小容差把恰落在右边界的坐标推进到下一宿；末宿兜底浮点残差。
    if (coord < acc + width - 1e-9 || isLast) {
      double degree = coord - acc;
      if (degree < 0) degree = 0.0;
      return ConstellationDegree(
          constellation: constellation, degree: degree);
    }
    acc += width;
  }
  // starInnOrder 非空时不可达（上面 isLast 分支必返回）。
  throw ArgumentError('星宿顺序列表 (starInnOrder) 不能为空。');
}

/// 把①层角度增量翻译成新的对齐点绝对值。
///
/// [basePoint] 是拖拽起始时的对齐点（通常为 `alignmentPointAtConstellation`
/// 或 `BasePanelConfig.alignmentPointOverride`）；[angleDeltaRadians] 是①层
/// 产出的带符号弧度增量。返回归一化后的“宿+度数”绝对值。
ConstellationDegree resolveAlignmentPointFromDrag({
  required ZhouTianModel model,
  required ConstellationDegree basePoint,
  required double angleDeltaRadians,
}) {
  final span = _ringSpan(model);
  final baseCoordinate = constellationDegreeToRingCoordinate(model, basePoint);
  final deltaDegree = angleDeltaRadians / (2 * pi) * span;
  return ringCoordinateToConstellationDegree(model, baseCoordinate + deltaDegree);
}
