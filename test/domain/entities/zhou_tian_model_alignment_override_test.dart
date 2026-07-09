import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';

/// 两宿模型: 角(Jiao)=13°, 亢(Kang)=12.87°
ZhouTianModel _sampleModel() => ZhouTianModel(
      systemType: CelestialCoordinateSystem.Ecliptic,
      constellationSystemType: ConstellationSystemType.Classical,
      panelSystemType: PanelSystemType.Tropical,
      epochCorrection: 'none',
      totalDegree: 365.255,
      gongDegreeSeq: [
        GongDegree(gong: EnumTwelveGong.Zi, degree: 30.44),
        GongDegree(gong: EnumTwelveGong.Chou, degree: 30.44),
      ],
      starInnDegreeSeq: [
        ConstellationDegree(
            constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 13),
        ConstellationDegree(
            constellation: Enum28Constellations.Kang_Jin_Long, degree: 12.87),
      ],
      alignmentPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 1.72),
      alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0),
      zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
      zeroPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 1.72),
      zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0),
      celestialLongitude: 0.0,
      zeroPointOffsetToNow: 0.0,
      rightAscension: 0.0,
      specificationList: const [],
      gongOrder: [EnumTwelveGong.Zi, EnumTwelveGong.Chou],
      starInnOrder: [
        Enum28Constellations.Jiao_Mu_Jiao,
        Enum28Constellations.Kang_Jin_Long,
      ],
    );

void main() {
  group('applyOverrides · alignmentPointOverride', () {
    test('null → 与其他覆写均空时返回同一实例', () {
      final m = _sampleModel();
      expect(identical(m.applyOverrides(alignmentPointOverride: null), m),
          isTrue);
    });

    test('非空 → alignmentPointAtConstellation 与 zeroPointAtConstellation 被替换为同一值',
        () {
      final m = _sampleModel();
      final override = ConstellationDegree(
          constellation: Enum28Constellations.Kang_Jin_Long, degree: 3.5);
      final r = m.applyOverrides(alignmentPointOverride: override);

      expect(identical(r, m), isFalse, reason: '有覆写必须返回克隆');
      expect(r.alignmentPointAtConstellation.constellation,
          Enum28Constellations.Kang_Jin_Long);
      expect(r.alignmentPointAtConstellation.degree, closeTo(3.5, 1e-9));
      expect(r.zeroPointAtConstellation.constellation,
          Enum28Constellations.Kang_Jin_Long);
      expect(r.zeroPointAtConstellation.degree, closeTo(3.5, 1e-9));
    });

    test('非空 → alignmentPointAtGong / zeroPointAtGong / gongDegreeSeq / starInnDegreeSeq 均不变',
        () {
      final m = _sampleModel();
      final override = ConstellationDegree(
          constellation: Enum28Constellations.Kang_Jin_Long, degree: 3.5);
      final r = m.applyOverrides(alignmentPointOverride: override);

      expect(r.alignmentPointAtGong.gong, EnumTwelveGong.Xu);
      expect(r.alignmentPointAtGong.degree, 0);
      expect(r.zeroPointAtGong.gong, EnumTwelveGong.Xu);
      expect(r.zeroPointAtGong.degree, 0);
      expect(r.gongDegreeSeq.map((g) => g.degree).toList(),
          equals(m.gongDegreeSeq.map((g) => g.degree).toList()));
      expect(r.starInnDegreeSeq.map((c) => c.degree).toList(),
          equals(m.starInnDegreeSeq.map((c) => c.degree).toList()));
    });

    test('非空 → 原缓存实例不被 mutate', () {
      final m = _sampleModel();
      final override = ConstellationDegree(
          constellation: Enum28Constellations.Kang_Jin_Long, degree: 3.5);
      m.applyOverrides(alignmentPointOverride: override);

      expect(m.alignmentPointAtConstellation.constellation,
          Enum28Constellations.Jiao_Mu_Jiao);
      expect(m.alignmentPointAtConstellation.degree, 1.72);
      expect(m.zeroPointAtConstellation.constellation,
          Enum28Constellations.Jiao_Mu_Jiao);
      expect(m.zeroPointAtConstellation.degree, 1.72);
    });

    test('优先级: alignmentPointOverride 覆盖岁差 offset（zeroPoint 取 override 绝对值，不叠加偏移）',
        () {
      final m = _sampleModel();
      final override = ConstellationDegree(
          constellation: Enum28Constellations.Kang_Jin_Long, degree: 3.5);
      final r = m.applyOverrides(
        alignmentPointOverride: override,
        offsetTier: ConstellationOffsetTier.adjusted, // 默认 +14°
      );

      // zeroPointAtConstellation 应等于 override 绝对值，而非 override.degree + 14
      expect(r.zeroPointAtConstellation.constellation,
          Enum28Constellations.Kang_Jin_Long);
      expect(r.zeroPointAtConstellation.degree, closeTo(3.5, 1e-9));
    });
  });
}
