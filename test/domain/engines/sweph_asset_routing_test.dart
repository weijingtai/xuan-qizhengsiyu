import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/domain/engines/sweph_engine.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';

/// 记录请求的 asset 名称并返回最小有效 JSON 的假 repo。
class _RecordingRepo implements QiZhengEphemerisResourceRepository {
  String? requestedName;
  String? returnJson;

  @override
  Future<String> loadEphemerisResource(String resourceName) async {
    requestedName = resourceName;
    return returnJson ?? _minimalModelJson();
  }
}

String _minimalModelJson() {
  final model = ZhouTianModel(
    systemType: CelestialCoordinateSystem.Ecliptic,
    constellationSystemType: ConstellationSystemType.Classical,
    panelSystemType: PanelSystemType.Tropical,
    epochCorrection: 'none',
    totalDegree: 360.0,
    gongDegreeSeq: [],
    starInnDegreeSeq: [],
    alignmentPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0),
    alignmentPointAtGong:
        GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
    zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
    zeroPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0),
    zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
    celestialLongitude: 0.0,
    zeroPointOffsetToNow: 0.0,
    rightAscension: 0.0,
    specificationList: [],
    gongOrder: [EnumTwelveGong.Mao],
    starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao],
  );
  return jsonEncode(model.toJson());
}

void main() {
  test('Ecliptic×Tropical×Classical → ecliptic_tropical_classical.json', () async {
    final repo = _RecordingRepo();
    final engine = SwephEngine(ephemerisRes: repo);
    await engine.getSystemDefinition(BasePanelConfig.defaultBasicPanelConfig());
    expect(repo.requestedName, 'ecliptic_tropical_classical.json');
  });

  test('SkyEquatorial → yuan_shoushi_chidao_hengxin.json', () async {
    final repo = _RecordingRepo();
    final engine = SwephEngine(ephemerisRes: repo);
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial,
    );
    await engine.getSystemDefinition(cfg);
    expect(repo.requestedName, 'yuan_shoushi_chidao_hengxin.json');
  });

  test('Equatorial 复用赤道基准资产 yuan_shoushi_chidao_hengxin.json', () async {
    final repo = _RecordingRepo();
    final engine = SwephEngine(ephemerisRes: repo);
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.Equatorial,
    );
    await engine.getSystemDefinition(cfg);
    expect(repo.requestedName, 'yuan_shoushi_chidao_hengxin.json');
  });

  test('PseudoEcliptic 复用赤道基准资产 yuan_shoushi_chidao_hengxin.json', () async {
    final repo = _RecordingRepo();
    final engine = SwephEngine(ephemerisRes: repo);
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.PseudoEcliptic,
    );
    await engine.getSystemDefinition(cfg);
    expect(repo.requestedName, 'yuan_shoushi_chidao_hengxin.json');
  });

  test('applyOverrides 使用命名参透传 A 层字段', () async {
    // 使用返回特定 degree 的 JSON，验证覆写生效
    final repo = _RecordingRepo();
    repo.returnJson = _minimalModelJson();
    final engine = SwephEngine(ephemerisRes: repo);
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      zhouTianModelOverride: EnumZhouTianModel.degree36525,
    );
    final model = await engine.getSystemDefinition(cfg);
    expect(model.totalDegree, 365.2575,
        reason: 'zhouTianModelOverride 经命名参 applyOverrides 应生效');
  });
}
