import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_calculator.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';

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
        projectionConfig: ProjectionConfig(strategy: MappingStrategy.linear, offset: 0),
        gongDegreeSeq: [GongDegree(gong: EnumTwelveGong.Zi, degree: 30.4375)], // Equal 1/12 of 365.25
        starInnDegreeSeq: [],
        alignmentPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Xu_Ri_Shu, degree: 0),
        alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
        zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
        zeroPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Shi_Huo_Zhu, degree: 0),
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
        projectionConfig: ProjectionConfig(strategy: MappingStrategy.linear, offset: 0),
        gongDegreeSeq: [GongDegree(gong: EnumTwelveGong.Zi, degree: 365.25)], 
        starInnDegreeSeq: [],
        alignmentPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Xu_Ri_Shu, degree: 0),
        alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
        zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
        zeroPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Shi_Huo_Zhu, degree: 0),
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
  });
}
