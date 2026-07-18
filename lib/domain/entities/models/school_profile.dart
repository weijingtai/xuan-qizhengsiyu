import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';

/// 流派档案：一个「流派 × 典籍」对应一整套 A 层默认。
/// 仿 `SiYuProfile`；只承载阶段一冻结的 A 层字段，不新增维度。
class SchoolProfile {
  final String id;
  final String name;
  final EnumSchoolType school;
  final String classicBook;

  // ——— 一整套 A 层默认（对齐 BasePanelConfig 字段名）———
  final CelestialCoordinateSystem coordinate;
  final PanelSystemType panelSystemType;
  final ConstellationSystemType constellationSystemType;
  final EnumZhouTianModel? zhouTianModelOverride;
  final ProjectionConfig? projectionOverride;
  final EnumZeroPointRef? zeroPointRef;
  final ConstellationOffsetTier? offsetTier;
  final double? constellationOffsetDeg;

  /// 关联四余档案 id（可空；四余星历由 SiYuProfile 体系另行解析）
  final String? siYuProfileId;

  const SchoolProfile({
    required this.id,
    required this.name,
    required this.school,
    required this.classicBook,
    required this.coordinate,
    required this.panelSystemType,
    required this.constellationSystemType,
    this.zhouTianModelOverride,
    this.projectionOverride,
    this.zeroPointRef,
    this.offsetTier,
    this.constellationOffsetDeg,
    this.siYuProfileId,
  });
}
