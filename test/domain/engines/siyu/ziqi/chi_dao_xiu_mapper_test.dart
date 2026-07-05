import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/chi_dao_xiu_mapper.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  test('赤道经度落宿：某宿起点→该宿0度，宿末→次宿0度', () {
    final model = ZhouTianModel(
      systemType: CelestialCoordinateSystem.Equatorial,
      constellationSystemType: ConstellationSystemType.Classical,
      panelSystemType: PanelSystemType.Sidereal,
      epochCorrection: 'Test',
      totalDegree: 365.25,
      gongDegreeSeq: List.generate(
          12,
          (i) => GongDegree(
              gong: EnumTwelveGong.values[i], degree: 365.25 / 12)),
      starInnDegreeSeq: List.generate(
          28,
          (i) => ConstellationDegree(
              constellation: Enum28Constellations.values[i],
              degree: 365.25 / 28)),
      alignmentPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0.0),
      alignmentPointAtGong:
          GongDegree(gong: EnumTwelveGong.Chou, degree: 15.0),
      zeroPointJieQi: TwentyFourJieQi.DONG_ZHI,
      zeroPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Ji_Shui_Bao, degree: 0.0),
      zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Chou, degree: 15.0),
      celestialLongitude: 0.0,
      zeroPointOffsetToNow: 0.0,
      rightAscension: 0.0,
      specificationList: [],
      gongOrder: EnumTwelveGong.values.toList(),
      starInnOrder: Enum28Constellations.values.toList(),
    );

    final mapper = ChiDaoXiuMapper(model);
    final start = mapper.xiuStartLongitude(Enum28Constellations.Jiao_Mu_Jiao);
    final mapped = mapper.toXiuDegree(start);
    expect(mapped.xiu, Enum28Constellations.Jiao_Mu_Jiao);
    expect(mapped.deg, closeTo(0, 1e-6));

    // Next constellation
    final nextStart = mapper.xiuStartLongitude(Enum28Constellations.Kang_Jin_Long);
    final nextMapped = mapper.toXiuDegree(nextStart);
    expect(nextMapped.xiu, Enum28Constellations.Kang_Jin_Long);
    expect(nextMapped.deg, closeTo(0, 1e-6));

    // A degree inside Jiao
    final insideMapped = mapper.toXiuDegree(start + 5.0);
    expect(insideMapped.xiu, Enum28Constellations.Jiao_Mu_Jiao);
    expect(insideMapped.deg, closeTo(5.0, 1e-6));
  });
}
