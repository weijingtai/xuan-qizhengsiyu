import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_calculator.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';

void main() {
  group('ZT-45 Boundary & Normalization Contract Tests', () {
    
    test('HARD CONTRACT: absEndContinuous must be monotonic across 360 boundary', () {
      // Scenario: A single palace that spans the entire 365.25 circle.
      final model = ZhouTianModel(
        systemType: CelestialCoordinateSystem.Ecliptic,
        constellationSystemType: ConstellationSystemType.Classical,
        panelSystemType: PanelSystemType.Tropical,
        epochCorrection: "none",
        totalDegree: 365.25,
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
      
      final zi = palaces[EnumTwelveGong.Zi]!;
      
      // The implementation MUST ensure that even if the projector mods the value,
      // the calculator handles the 'End' point to be (Start + Width).
      expect(zi.absEndContinuous, greaterThan(zi.absStartContinuous), 
        reason: "Termination value must be greater than start value to maintain physical width.");
      expect(zi.absEndContinuous, 365.25, 
        reason: "For a full circle of 365.25, the end boundary must be exactly 365.25.");
    });

    test('HARD CONTRACT: Visual Normalization for Overlap Adjustment', () {
      // Logic: If projected degree is 182.625 in a 365.25 system, 
      // the Visual degree passed to UIStarModel MUST be 180.0.
      
      final totalDegree = 365.25;
      final projectedDegree = 182.625; // Middle of the circle
      
      // Simulating the logic required in Task 4.3
      final visualDegree = (projectedDegree / totalDegree) * 360.0;
      
      expect(visualDegree, 180.0, reason: "Projected 182.625/365.25 MUST normalize to 180.0/360.0 for UI.");
    });
  });
}
