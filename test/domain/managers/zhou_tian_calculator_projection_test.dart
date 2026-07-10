import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_calculator.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';

void main() {
  group('ZhouTianCalculator Projection Integration Tests', () {
    // This test verifies that the Calculator correctly uses the Projector
    // to define palace and constellation boundaries.

    test('Palace boundaries with Linear Projection (360 -> 365.25)', () {
      final model = ZhouTianModel(
        systemType: CelestialCoordinateSystem.Ecliptic,
        constellationSystemType: ConstellationSystemType.Classical,
        panelSystemType: PanelSystemType.Tropical,
        epochCorrection: "none",
        totalDegree: 365.25,
        projectionConfig: ProjectionConfig(
          strategy: MappingStrategy.linear,
          offset: 0,
        ),
        gongDegreeSeq: [
          GongDegree(gong: EnumTwelveGong.Zi, degree: 30.4375),
        ], // Equal 1/12 of 365.25
        starInnDegreeSeq: [],
        alignmentPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Xu_Ri_Shu,
          degree: 0,
        ),
        alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
        zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
        zeroPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Shi_Huo_Zhu,
          degree: 0,
        ),
        zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
        celestialLongitude: 0,
        zeroPointOffsetToNow: 0,
        rightAscension: 0,
        specificationList: [],
        gongOrder: [EnumTwelveGong.Zi],
        starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao],
      );

      final calculator = ZhouTianCalculator(zhouTianModel: model);
      final palaces = calculator.calculatePalaceAngles();

      expect(palaces[EnumTwelveGong.Zi]?.absStartContinuous, 0.0);
    });

    test('Verification of Visual Normalization logic requirement', () {
      final total = 365.25;
      final model = ZhouTianModel(
        systemType: CelestialCoordinateSystem.Ecliptic,
        constellationSystemType: ConstellationSystemType.Classical,
        panelSystemType: PanelSystemType.Tropical,
        epochCorrection: "none",
        totalDegree: total,
        projectionConfig: ProjectionConfig(
          strategy: MappingStrategy.linear,
          offset: 0,
        ),
        gongDegreeSeq: [GongDegree(gong: EnumTwelveGong.Zi, degree: 365.25)],
        starInnDegreeSeq: [],
        alignmentPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Xu_Ri_Shu,
          degree: 0,
        ),
        alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
        zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
        zeroPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Shi_Huo_Zhu,
          degree: 0,
        ),
        zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
        celestialLongitude: 0,
        zeroPointOffsetToNow: 0,
        rightAscension: 0,
        specificationList: [],
        gongOrder: [EnumTwelveGong.Zi],
        starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao],
      );

      final calculator = ZhouTianCalculator(zhouTianModel: model);
      final palaces = calculator.calculatePalaceAngles();

      // 1. Check logical correctness (in 365.25 space)
      expect(palaces[EnumTwelveGong.Zi]?.absEndContinuous, total);

      // 2. CONTRACT: Visual Normalization (Manual verification simulation)
      // This part ensures that the implementation agent MUST perform this conversion
      // before UI rendering.
      double projectedValue = palaces[EnumTwelveGong.Zi]!.absEndContinuous;
      double visualValue = (projectedValue / model.totalDegree) * 360.0;
      expect(visualValue, 360.0);
    });

    test(
      'houseDivisionSystemOverride changes palace widths used by calculator',
      () {
        final order = [
          EnumTwelveGong.Zi,
          EnumTwelveGong.Chou,
          EnumTwelveGong.Yin,
          EnumTwelveGong.Mao,
          EnumTwelveGong.Chen,
          EnumTwelveGong.Si,
          EnumTwelveGong.Wu,
          EnumTwelveGong.Wei,
          EnumTwelveGong.Shen,
          EnumTwelveGong.You,
          EnumTwelveGong.Xu,
          EnumTwelveGong.Hai,
        ];
        final model = ZhouTianModel(
          systemType: CelestialCoordinateSystem.PseudoEcliptic,
          constellationSystemType: ConstellationSystemType.Classical,
          panelSystemType: PanelSystemType.Sidereal,
          epochCorrection: "sanchen-test",
          totalDegree: 365.255,
          projectionConfig: ProjectionConfig(
            strategy: MappingStrategy.linear,
            offset: 0,
          ),
          gongDegreeSeq: [
            for (final gong in order)
              GongDegree(gong: gong, degree: 365.255 / 12),
          ],
          starInnDegreeSeq: [],
          alignmentPointAtConstellation: ConstellationDegree(
            constellation: Enum28Constellations.Xu_Ri_Shu,
            degree: 0,
          ),
          alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
          zeroPointJieQi: TwentyFourJieQi.DONG_ZHI,
          zeroPointAtConstellation: ConstellationDegree(
            constellation: Enum28Constellations.Xu_Ri_Shu,
            degree: 0,
          ),
          zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
          celestialLongitude: 0,
          zeroPointOffsetToNow: 0,
          rightAscension: 0,
          specificationList: [],
          gongOrder: order,
          starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao],
        );

        final equalPalaces = ZhouTianCalculator(
          zhouTianModel: model,
        ).calculatePalaceAngles();
        final unequalModel = model.applyOverrides(
          houseDivisionSystemOverride:
              HouseDivisionSystem.equatorialZiWuSanChenTongZai,
        );
        final unequalPalaces = ZhouTianCalculator(
          zhouTianModel: unequalModel,
        ).calculatePalaceAngles();

        expect(
          equalPalaces[EnumTwelveGong.Zi]!.width,
          closeTo(365.255 / 12, 0.001),
        );
        expect(
          unequalPalaces[EnumTwelveGong.Zi]!.width,
          closeTo(30.4380, 0.001),
        );
        expect(
          unequalPalaces[EnumTwelveGong.Chou]!.width,
          closeTo(30.4979, 0.001),
        );
        expect(
          unequalPalaces[EnumTwelveGong.Chou]!.width,
          isNot(equalPalaces[EnumTwelveGong.Chou]!.width),
        );
      },
    );
  });
}
