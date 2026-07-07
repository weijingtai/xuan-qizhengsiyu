import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

ZhouTianModel _buildBaselineModel() {
  return ZhouTianModel(
    systemType: CelestialCoordinateSystem.Ecliptic,
    constellationSystemType: ConstellationSystemType.Classical,
    panelSystemType: PanelSystemType.Tropical,
    epochCorrection: 'default',
    totalDegree: 360.0,
    gongDegreeSeq: [
      GongDegree(gong: EnumTwelveGong.Zi, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Chou, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Yin, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Mao, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Chen, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Si, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Wu, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Wei, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Shen, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.You, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Xu, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Hai, degree: 30.0),
    ],
    starInnDegreeSeq: [
      ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 12.0),
      ConstellationDegree(
          constellation: Enum28Constellations.Kang_Jin_Long, degree: 10.0),
    ],
    alignmentPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Xu_Ri_Shu, degree: 6.0),
    alignmentPointAtGong:
        GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
    zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
    zeroPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Shi_Huo_Zhu, degree: 6.5),
    zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0.0),
    celestialLongitude: 0.0,
    zeroPointOffsetToNow: 0.0,
    rightAscension: 0.0,
    specificationList: const ['baseline'],
    gongOrder: EnumTwelveGong.listAll,
    starInnOrder: [
      Enum28Constellations.Jiao_Mu_Jiao,
      Enum28Constellations.Kang_Jin_Long,
    ],
  );
}

class _FakeRepo implements QiZhengZhouTianModelRepository {
  final ZhouTianModel model;
  _FakeRepo(this.model);

  @override
  Future<List<QiZhengZhouTianModelContract>>
      loadBuiltInZhouTianModels() async {
    return [
      QiZhengZhouTianModelContract(
          jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>)
    ];
  }
}

void main() {
  /// 基线：默认 config 通过完整管线得到的模型。
  ZhouTianModel _baseline() {
    final model = _buildBaselineModel();
    final manager = ZhouTianModelManager(repository: _FakeRepo(model));
    manager.setModelsForTesting({
      '黄道制_回归制_古宿制': model,
    });
    return manager.getZhouTianModelBy(
      BasePanelConfig.defaultBasicPanelConfig(),
    );
  }

  test('(a) 旧 JSON 缺全部 A 层新字段 → 默认 config 与基线一致', () {
    final oldJson = BasePanelConfig.defaultBasicPanelConfig().toJson()
      ..remove('zeroPointRef')
      ..remove('offsetTier')
      ..remove('constellationOffsetDeg')
      ..remove('starInnDegreeOverrides');
    final oldCfg = BasePanelConfig.fromJson(oldJson);

    final baselineModel = _baseline();
    final model = _buildBaselineModel();
    final manager = ZhouTianModelManager(repository: _FakeRepo(model));
    manager.setModelsForTesting({
      '黄道制_回归制_古宿制': model,
    });
    final result = manager.getZhouTianModelBy(oldCfg);

    expect(result.totalDegree, baselineModel.totalDegree);
    expect(result.starInnDegreeSeq.length, baselineModel.starInnDegreeSeq.length);
    expect(result.zeroPointAtConstellation.degree,
        baselineModel.zeroPointAtConstellation.degree);
  });

  test('(b) 新建默认 config → 基线一致', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig();
    final baselineModel = _baseline();
    final model = _buildBaselineModel();
    final manager = ZhouTianModelManager(repository: _FakeRepo(model));
    manager.setModelsForTesting({
      '黄道制_回归制_古宿制': model,
    });
    final result = manager.getZhouTianModelBy(cfg);

    expect(result.totalDegree, baselineModel.totalDegree);
    expect(result.starInnDegreeSeq.length, baselineModel.starInnDegreeSeq.length);
  });

  test('(c) 显式 degree360+linear → 与 null 默认一致', () {
    final cfgNull = BasePanelConfig.defaultBasicPanelConfig(); // zhouTianModelOverride=null
    final cfg360 = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      zhouTianModelOverride: null,
      projectionOverride: null,
    );

    final model = _buildBaselineModel();
    final manager = ZhouTianModelManager(repository: _FakeRepo(model));
    manager.setModelsForTesting({
      '黄道制_回归制_古宿制': model,
    });

    final r1 = manager.getZhouTianModelBy(cfgNull);
    final r2 = manager.getZhouTianModelBy(cfg360);

    expect(r2.totalDegree, r1.totalDegree);
    expect(r2.starInnDegreeSeq.length, r1.starInnDegreeSeq.length);
  });

  test('(d) 默认 config 不含 A 层字段副作用', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig();
    expect(cfg.zeroPointRef, isNull);
    expect(cfg.offsetTier, isNull);
    expect(cfg.constellationOffsetDeg, isNull);
    expect(cfg.starInnDegreeOverrides, isNull);

    final model = _buildBaselineModel();
    final manager = ZhouTianModelManager(repository: _FakeRepo(model));
    manager.setModelsForTesting({
      '黄道制_回归制_古宿制': model,
    });
    final result = manager.getZhouTianModelBy(cfg);

    // 全 null 默认不应改变模型的关键值
    expect(result.totalDegree, model.totalDegree);
    expect(result.starInnDegreeSeq.length, model.starInnDegreeSeq.length);
    expect(result.zeroPointAtConstellation.degree,
        model.zeroPointAtConstellation.degree);
  });
}
