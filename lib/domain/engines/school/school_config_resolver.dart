import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'school_profile.dart';
import 'built_in_school_profiles.dart';

/// 把流派档案里的一整套 A 层默认套进给定 config。
/// 只改 A 层轴字段，其余（settle/location/人物）原样保留。
class SchoolConfigResolver {
  BasePanelConfig applyProfile(BasePanelConfig base, SchoolProfile p) {
    return BasePanelConfig(
      celestialCoordinateSystem: p.coordinate,
      houseDivisionSystem: base.houseDivisionSystem,
      panelSystemType: p.panelSystemType,
      constellationSystemType: p.constellationSystemType,
      settleLifeType: base.settleLifeType,
      settleBodyType: base.settleBodyType,
      islifeGongBySunRealTimeLocation: base.islifeGongBySunRealTimeLocation,
      lifeCountingToGong: base.lifeCountingToGong,
      bodyCountingToGong: base.bodyCountingToGong,
      rahuKetuConvention: base.rahuKetuConvention,
      ziQiAlgorithm: base.ziQiAlgorithm,
      ziQiPeriod: base.ziQiPeriod,
      ziQiEpochSet: base.ziQiEpochSet,
      ziQiChiDaoStandard: base.ziQiChiDaoStandard,
      siYuProfileId: p.siYuProfileId ?? base.siYuProfileId,
      siYuOverrides: base.siYuOverrides,
      siYuCoordinateOverride: base.siYuCoordinateOverride,
      zhouTianModelOverride: p.zhouTianModelOverride,
      projectionOverride: p.projectionOverride,
      zeroPointRef: p.zeroPointRef,
      offsetTier: p.offsetTier,
      constellationOffsetDeg: p.constellationOffsetDeg,
      starInnDegreeOverrides: base.starInnDegreeOverrides,
    );
  }

  BasePanelConfig applyById(BasePanelConfig base, String profileId) =>
      applyProfile(base, BuiltInSchoolProfiles.byId(profileId));
}
