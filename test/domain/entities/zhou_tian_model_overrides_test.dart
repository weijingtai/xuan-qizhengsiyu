import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';

void main() {
  ZhouTianModel _baseModel() => ZhouTianModel(
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

  group('ZhouTianModel.applyOverrides 覆写与缓存安全', () {
    test('两字段均 null 时返回同一实例 (identical)', () {
      final original = _baseModel();
      final result = original.applyOverrides();
      expect(identical(original, result), isTrue,
          reason: '零配置覆写必须返回原实例，避免无意义的克隆');
      expect(result.totalDegree, 360.0);
      expect(result.projectionConfig, isNull);
    });

    test('设 degree36525 → totalDegree 覆写为 365.2575', () {
      final original = _baseModel();
      final result =
          original.applyOverrides(zhouTianModelOverride: EnumZhouTianModel.degree36525);
      expect(result.totalDegree, 365.2575);
      expect(identical(original, result), isFalse,
          reason: '有覆写时必须返回克隆');
    });

    test('设 projectionOverride → projectionConfig 生效', () {
      final original = _baseModel();
      final overrideConfig = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        huangChiDaoDiffType: HuangChiDaoDiffType.daren,
        springEquinoxAnchor: 6.0,
      );
      final result = original.applyOverrides(projectionOverride: overrideConfig);
      expect(result.projectionConfig?.strategy,
          MappingStrategy.tuiBianHuangDao);
      expect(result.projectionConfig?.huangChiDaoDiffType,
          HuangChiDaoDiffType.daren);
      expect(result.projectionConfig?.springEquinoxAnchor, 6.0);
    });

    test('同时覆写 totalDegree 和 projectionConfig', () {
      final original = _baseModel();
      final overrideConfig = ProjectionConfig(
        strategy: MappingStrategy.linear,
        offset: 3.0,
      );
      final result = original.applyOverrides(
          zhouTianModelOverride: EnumZhouTianModel.degree36525,
          projectionOverride: overrideConfig);
      expect(result.totalDegree, 365.2575);
      expect(result.projectionConfig?.strategy, MappingStrategy.linear);
      expect(result.projectionConfig?.offset, 3.0);
    });

    test('调用 applyOverrides 后原缓存实例字段不被 mutate', () {
      final original = _baseModel();
      final originalTotal = original.totalDegree;
      final originalProj = original.projectionConfig;

      final overrideConfig = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        huangChiDaoDiffType: HuangChiDaoDiffType.jiyuan,
      );
      original.applyOverrides(
          zhouTianModelOverride: EnumZhouTianModel.degree36525,
          projectionOverride: overrideConfig);

      expect(original.totalDegree, originalTotal,
          reason: '原实例 totalDegree 不应被 mutate');
      expect(original.projectionConfig, originalProj,
          reason: '原实例 projectionConfig 不应被 mutate');
    });

    test('copyWith 覆盖 totalDegree', () {
      final original = _baseModel();
      final cloned = original.copyWith(totalDegree: 365.2575);
      expect(cloned.totalDegree, 365.2575);
      expect(identical(original, cloned), isFalse);
    });

    test('copyWith 覆盖 projectionConfig', () {
      final original = _baseModel();
      final overrideConfig = ProjectionConfig(
        strategy: MappingStrategy.piecewise,
        sourcePoints: [0.0, 180.0],
        targetPoints: [0.0, 182.0],
      );
      final cloned = original.copyWith(projectionConfig: overrideConfig);
      expect(cloned.projectionConfig?.strategy, MappingStrategy.piecewise);
      expect(original.projectionConfig, isNull,
          reason: '原实例 projectionConfig 应不变');
    });
  });

  group('applyOverrides 扩展覆盖（命名参 + 逐宿覆写 + 偏移量）', () {
    ZhouTianModel _sampleModel() => _baseModel().copyWith(
          starInnDegreeSeq: [
            ConstellationDegree(
                constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0),
            ConstellationDegree(
                constellation: Enum28Constellations.Kang_Jin_Long,
                degree: 12.87),
          ],
          starInnOrder: [
            Enum28Constellations.Jiao_Mu_Jiao,
            Enum28Constellations.Kang_Jin_Long,
          ],
        );

    test('applyOverrides 全 null → identical(this)', () {
      final m = _sampleModel();
      expect(identical(m.applyOverrides(), m), isTrue);
    });

    test('applyOverrides 逐宿覆写 → 克隆生效且不 mutate 原实例', () {
      final m = _sampleModel();
      final before = List.of(m.starInnDegreeSeq);
      final r = m.applyOverrides(
        starInnDegreeOverrides: {Enum28Constellations.Jiao_Mu_Jiao: 12.3},
      );
      expect(identical(r, m), isFalse);
      expect(m.starInnDegreeSeq, equals(before),
          reason: '原实例列表不应被 mutate');
      final idx = r.starInnOrder.indexOf(Enum28Constellations.Jiao_Mu_Jiao);
      expect(r.starInnDegreeSeq[idx].degree, 12.3);
    });

    test('applyOverrides 偏移量 → 零点平移、原实例不变', () {
      final m = _sampleModel();
      final r = m.applyOverrides(
        offsetTier: ConstellationOffsetTier.adjusted, // 默认 14°
      );
      expect(identical(r, m), isFalse);
      expect(r.zeroPointAtConstellation.degree,
          closeTo(m.zeroPointAtConstellation.degree + 14.0, 1e-9));
    });
  });
}
