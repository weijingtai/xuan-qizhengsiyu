import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/managers/panel_system_resolver.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';

void main() {
  final r = PanelSystemResolver();

  test('现代黄道 + 365.25 = 矛盾并给 suggestedFix', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      zhouTianModelOverride: EnumZhouTianModel.degree36525,
    );
    final c = r.validate(cfg);
    expect(c.isCoherent, isFalse);
    expect(c.warnings.any((w) => w.contains('365')), isTrue);
    expect(c.suggestedFix, isNotNull);
  });

  test('现代黄道 + 推变黄道 = 矛盾', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      projectionOverride: ProjectionConfig(
          strategy: MappingStrategy.tuiBianHuangDao,
          huangChiDaoDiffType: HuangChiDaoDiffType.shoushi),
    );
    expect(r.validate(cfg).isCoherent, isFalse);
  });

  test('默认 config = 一致、无警告', () {
    expect(r.validate(BasePanelConfig.defaultBasicPanelConfig()).isCoherent, isTrue);
  });

  test('规则④：回归制 + 冬至起点 → 语义提示', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      panelSystemType: PanelSystemType.Tropical,
      zeroPointRef: EnumZeroPointRef.dongzhi,
    );
    final c = r.validate(cfg);
    expect(c.warnings.any((w) => w.contains('回归') || w.contains('冬至')), isTrue);
  });

  test('规则④：回归制 + 春分起点 → 无④类提示（常规组合）', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      panelSystemType: PanelSystemType.Tropical,
      zeroPointRef: EnumZeroPointRef.chunfen,
    );
    final c = r.validate(cfg);
    expect(c.warnings.any((w) => w.contains('回归制通常配春分')), isFalse);
  });
}
