import '../../enums/enum_panel_system_type.dart';
import '../../enums/enum_zhou_tian_model.dart';
import '../../enums/enum_zero_point_ref.dart';
import '../entities/models/panel_config.dart';
import '../entities/models/projection_config.dart';

class PanelSystemCheck {
  final bool isCoherent;
  final List<String> warnings;
  final BasePanelConfig? suggestedFix;
  const PanelSystemCheck(this.isCoherent, this.warnings, this.suggestedFix);
}

class PanelSystemResolver {
  PanelSystemCheck validate(BasePanelConfig config,
      {Set<String> availableAssetKeys = const {}}) {
    final warnings = <String>[];
    BasePanelConfig? fix;
    final coord = config.celestialCoordinateSystem;
    final is365 = config.zhouTianModelOverride == EnumZhouTianModel.degree36525;
    final isTuiBian =
        config.projectionOverride?.strategy == MappingStrategy.tuiBianHuangDao;

    // ① 现代黄道/赤道 + 365.25 矛盾
    if ((coord == CelestialCoordinateSystem.Ecliptic ||
            coord == CelestialCoordinateSystem.Equatorial) &&
        is365) {
      warnings.add('现代黄道/赤道为 360 度制，与古度 365.25 冲突');
      fix = (fix ?? config).copyWith(zhouTianModelOverride: null);
    }
    // ② 现代黄道 + 推变黄道 矛盾
    if (coord == CelestialCoordinateSystem.Ecliptic && isTuiBian) {
      warnings.add('黄道制本身不做赤黄投影，推变黄道无意义');
      fix = (fix ?? config).copyWith(projectionOverride: null);
    }
    // ③ 古黄道 + 线性 提示退化
    if (coord == CelestialCoordinateSystem.PseudoEcliptic && !isTuiBian) {
      warnings.add('古黄道未选推黄道算法，将退化为直接 365.25÷360 缩放');
    }
    // ④ 回归/恒星 与 起点(春分/冬至) 的语义匹配（非阻断提示）
    final ref = config.zeroPointRef;
    if (ref != null) {
      final isTropical = config.panelSystemType == PanelSystemType.Tropical;
      if (isTropical && ref == EnumZeroPointRef.dongzhi) {
        warnings.add('回归制通常配春分起点，当前选了冬至起点，请确认');
      }
      if (!isTropical && ref == EnumZeroPointRef.chunfen) {
        warnings.add('恒星制通常配冬至/固定恒星起点，当前选了春分起点，请确认');
      }
    }
    // ⑤ 逐宿覆写 提示核对
    final overrides = config.starInnDegreeOverrides;
    if (overrides != null && overrides.isNotEmpty) {
      final target = is365 ? 365.2575 : 360.0;
      warnings.add('已覆写 ${overrides.length} 宿弧度，请确认二十八宿总和≈$target');
    }
    // ⑥ 资产缺失
    if (availableAssetKeys.isNotEmpty) {
      final key =
          '${coord.name}_${config.panelSystemType.name}_${config.constellationSystemType.name}';
      if (!availableAssetKeys.contains(key)) {
        warnings.add('当前坐标×星盘×星宿组合暂无对应资产（$key）');
      }
    }
    return PanelSystemCheck(warnings.isEmpty, warnings, fix);
  }
}
