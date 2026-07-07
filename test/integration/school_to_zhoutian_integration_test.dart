import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/school/school_config_resolver.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

class _FakeRepo implements QiZhengZhouTianModelRepository {
  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async {
    return [];
  }
}

ZhouTianModel _buildBaselineModel(
    CelestialCoordinateSystem systemType, PanelSystemType panelSystemType, double totalDegree) {
  return ZhouTianModel(
    systemType: systemType,
    constellationSystemType: ConstellationSystemType.Classical,
    panelSystemType: panelSystemType,
    epochCorrection: 'default',
    totalDegree: totalDegree,
    gongDegreeSeq: [
      GongDegree(gong: EnumTwelveGong.Zi, degree: 30.0),
    ],
    starInnDegreeSeq: [
      ConstellationDegree(constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 12.0),
    ],
    alignmentPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Xu_Ri_Shu, degree: 6.0),
    alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
    zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
    zeroPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Shi_Huo_Zhu, degree: 6.5),
    zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0.0),
    celestialLongitude: 0.0,
    zeroPointOffsetToNow: 0.0,
    rightAscension: 0.0,
    specificationList: const ['baseline'],
    gongOrder: EnumTwelveGong.listAll,
    starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao],
  );
}

void main() {
  test('端到端集成金标：选流派 → 排盘模型真反映配置', () {
    final guolaoModel = _buildBaselineModel(CelestialCoordinateSystem.Ecliptic, PanelSystemType.Tropical, 360.0);
    final qintangModel = _buildBaselineModel(CelestialCoordinateSystem.SkyEquatorial, PanelSystemType.Sidereal, 365.2575);

    final manager = ZhouTianModelManager(repository: _FakeRepo());
    
    // We recreate the keys exactly as ZhouTianModelManager._createMapperKey does
    final glKey = '${CelestialCoordinateSystem.Ecliptic.name}_${PanelSystemType.Tropical.name}_${ConstellationSystemType.Classical.name}';
    final qtKey = '${CelestialCoordinateSystem.SkyEquatorial.name}_${PanelSystemType.Sidereal.name}_${ConstellationSystemType.Classical.name}';
    
    manager.setModelsForTesting({
      glKey: guolaoModel,
      qtKey: qintangModel,
      // fallback just in case '黄道制_回归制_古宿制' is indeed used by some internal mapping logic
      '黄道制_回归制_古宿制': guolaoModel,
      '天赤道_恒星制_古宿制': qintangModel,
    });

    final base = BasePanelConfig.defaultBasicPanelConfig();
    final resolver = SchoolConfigResolver();

    // 果老
    final glProfile = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.GuoLao);
    final glConfig = resolver.applyProfile(base, glProfile);
    final glResult = manager.getZhouTianModelBy(glConfig);
    expect(glResult.systemType, CelestialCoordinateSystem.Ecliptic);
    expect(glResult.totalDegree, 360.0);

    // 琴堂
    final qtProfile = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang);
    final qtConfig = resolver.applyProfile(base, qtProfile);
    final qtResult = manager.getZhouTianModelBy(qtConfig);
    expect(qtResult.systemType, CelestialCoordinateSystem.SkyEquatorial);
    expect(qtResult.totalDegree, 365.2575);
  });
}
