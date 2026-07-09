import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_calculator.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

/// 对齐星宿落在 starInnOrder 内，供 calculateConstellationAngles 使用。
ZhouTianModel _model() => ZhouTianModel(
      systemType: CelestialCoordinateSystem.Ecliptic,
      constellationSystemType: ConstellationSystemType.Classical,
      panelSystemType: PanelSystemType.Tropical,
      epochCorrection: 'none',
      totalDegree: 360.0,
      gongDegreeSeq: [
        for (final g in EnumTwelveGong.listAll)
          GongDegree(gong: g, degree: 30.0),
      ],
      starInnDegreeSeq: [
        ConstellationDegree(
            constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 12.0),
        ConstellationDegree(
            constellation: Enum28Constellations.Kang_Jin_Long, degree: 10.0),
      ],
      alignmentPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0.0),
      alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
      zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
      zeroPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0.0),
      zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
      celestialLongitude: 0.0,
      zeroPointOffsetToNow: 0.0,
      rightAscension: 0.0,
      specificationList: const [],
      gongOrder: EnumTwelveGong.listAll,
      starInnOrder: [
        Enum28Constellations.Jiao_Mu_Jiao,
        Enum28Constellations.Kang_Jin_Long,
      ],
    );

class _FakeRepo implements QiZhengZhouTianModelRepository {
  final List<ZhouTianModel> models;
  _FakeRepo(this.models);

  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async {
    return models
        .map((m) => QiZhengZhouTianModelContract(
            jsonDecode(jsonEncode(m.toJson())) as Map<String, dynamic>))
        .toList();
  }
}

BasePanelConfig _config({ConstellationDegree? alignmentPointOverride}) =>
    BasePanelConfig(
      celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      houseDivisionSystem: HouseDivisionSystem.equal,
      panelSystemType: PanelSystemType.Tropical,
      constellationSystemType: ConstellationSystemType.Classical,
      settleLifeType: EnumSettleLifeType.Mao,
      settleBodyType: EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation: true,
      alignmentPointOverride: alignmentPointOverride,
    );

void main() {
  group('集成: 切换 alignmentPointOverride 前后 calculateConstellationAngles 输出确实变', () {
    late ZhouTianModelManager manager;

    setUp(() {
      manager = ZhouTianModelManager(repository: _FakeRepo([_model()]));
      manager.addModelForTesting(_model());
    });

    test('override 为 null → 与资产自带对齐点一致', () {
      final m = manager.getZhouTianModelBy(_config());
      final angles = ZhouTianCalculator(zhouTianModel: m)
          .calculateConstellationAngles();
      // 对齐点 角0°，故 角 的连续绝对起点为 project(0)=0
      expect(angles[Enum28Constellations.Jiao_Mu_Jiao]!.absStartContinuous,
          closeTo(0.0, 1e-9));
    });

    test('override 非空 → 星宿环整体平移，输出与 null 时不同', () {
      final baseModel = manager.getZhouTianModelBy(_config());
      final baseAngles = ZhouTianCalculator(zhouTianModel: baseModel)
          .calculateConstellationAngles();

      final overriddenModel = manager.getZhouTianModelBy(_config(
        alignmentPointOverride: ConstellationDegree(
            constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 5.0),
      ));
      final overriddenAngles =
          ZhouTianCalculator(zhouTianModel: overriddenModel)
              .calculateConstellationAngles();

      final baseStart =
          baseAngles[Enum28Constellations.Jiao_Mu_Jiao]!.absStartContinuous;
      final overriddenStart = overriddenAngles[
              Enum28Constellations.Jiao_Mu_Jiao]!
          .absStartContinuous;

      // 对齐度 0→5，起点从 project(0)=0 平移到 project(-5) 归一化=355，确有变化
      expect(baseStart, closeTo(0.0, 1e-6));
      expect(overriddenStart, isNot(closeTo(baseStart, 1e-6)),
          reason: '切换 override 后星宿环起点必须改变');
      expect(overriddenStart, closeTo(355.0, 1e-6));
    });

    test('override 不污染缓存: 再次取 null 配置仍是资产原值', () {
      manager.getZhouTianModelBy(_config(
        alignmentPointOverride: ConstellationDegree(
            constellation: Enum28Constellations.Kang_Jin_Long, degree: 3.0),
      ));
      final again = manager.getZhouTianModelBy(_config());
      expect(again.alignmentPointAtConstellation.constellation,
          Enum28Constellations.Jiao_Mu_Jiao);
      expect(again.alignmentPointAtConstellation.degree, 0.0);
    });
  });
}
