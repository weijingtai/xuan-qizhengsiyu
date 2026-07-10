import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/calibration/alignment_point_resolver.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 构造一个 3 宿的小周天模型:
///   角(Jiao)=10°  亢(Kang)=20°  氐(Di)=30°   ringSpan = 60°
/// 环内坐标: 角[0,10)  亢[10,30)  氐[30,60)
ZhouTianModel _threeConstellationModel() => ZhouTianModel(
      systemType: CelestialCoordinateSystem.Ecliptic,
      constellationSystemType: ConstellationSystemType.Classical,
      panelSystemType: PanelSystemType.Tropical,
      epochCorrection: 'none',
      totalDegree: 60.0,
      gongDegreeSeq: const [],
      starInnDegreeSeq: [
        ConstellationDegree(
            constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 10),
        ConstellationDegree(
            constellation: Enum28Constellations.Kang_Jin_Long, degree: 20),
        ConstellationDegree(
            constellation: Enum28Constellations.Di_Tu_Lu, degree: 30),
      ],
      alignmentPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0),
      alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
      zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
      zeroPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0),
      zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
      celestialLongitude: 0.0,
      zeroPointOffsetToNow: 0.0,
      rightAscension: 0.0,
      specificationList: const [],
      gongOrder: [EnumTwelveGong.Mao],
      starInnOrder: [
        Enum28Constellations.Jiao_Mu_Jiao,
        Enum28Constellations.Kang_Jin_Long,
        Enum28Constellations.Di_Tu_Lu,
      ],
    );

void main() {
  group('constellationDegreeToRingCoordinate 宿度→环坐标', () {
    test('角0° → 0', () {
      final m = _threeConstellationModel();
      expect(
        constellationDegreeToRingCoordinate(
            m,
            ConstellationDegree(
                constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0)),
        0.0,
      );
    });

    test('亢10° → 20（角10 + 亢内10）', () {
      final m = _threeConstellationModel();
      expect(
        constellationDegreeToRingCoordinate(
            m,
            ConstellationDegree(
                constellation: Enum28Constellations.Kang_Jin_Long, degree: 10)),
        20.0,
      );
    });

    test('氐25° → 55（角10 + 亢20 + 氐内25）', () {
      final m = _threeConstellationModel();
      expect(
        constellationDegreeToRingCoordinate(
            m,
            ConstellationDegree(
                constellation: Enum28Constellations.Di_Tu_Lu, degree: 25)),
        55.0,
      );
    });

    test('星宿不在 starInnOrder → ArgumentError', () {
      final m = _threeConstellationModel();
      expect(
        () => constellationDegreeToRingCoordinate(
            m,
            ConstellationDegree(
                constellation: Enum28Constellations.Xu_Ri_Shu, degree: 0)),
        throwsArgumentError,
      );
    });
  });

  group('ringCoordinateToConstellationDegree 环坐标→宿度', () {
    test('9 → 角9°', () {
      final m = _threeConstellationModel();
      final cd = ringCoordinateToConstellationDegree(m, 9.0);
      expect(cd.constellation, Enum28Constellations.Jiao_Mu_Jiao);
      expect(cd.degree, closeTo(9.0, 1e-9));
    });

    test('边界 10 → 亢0°（左闭右开，边界归下一宿）', () {
      final m = _threeConstellationModel();
      final cd = ringCoordinateToConstellationDegree(m, 10.0);
      expect(cd.constellation, Enum28Constellations.Kang_Jin_Long);
      expect(cd.degree, closeTo(0.0, 1e-9));
    });

    test('负坐标 -5 → 归一化到 55 → 氐25°', () {
      final m = _threeConstellationModel();
      final cd = ringCoordinateToConstellationDegree(m, -5.0);
      expect(cd.constellation, Enum28Constellations.Di_Tu_Lu);
      expect(cd.degree, closeTo(25.0, 1e-9));
    });

    test('超一圈 65 → 归一化到 5 → 角5°', () {
      final m = _threeConstellationModel();
      final cd = ringCoordinateToConstellationDegree(m, 65.0);
      expect(cd.constellation, Enum28Constellations.Jiao_Mu_Jiao);
      expect(cd.degree, closeTo(5.0, 1e-9));
    });
  });

  group('resolveAlignmentPointFromDrag 角度增量→对齐点绝对值', () {
    test('正 1/4 圈（+π/2）从 角5° 前进 15° → 亢10°', () {
      final m = _threeConstellationModel();
      final cd = resolveAlignmentPointFromDrag(
        model: m,
        basePoint: ConstellationDegree(
            constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 5),
        angleDeltaRadians: pi / 2,
      );
      expect(cd.constellation, Enum28Constellations.Kang_Jin_Long);
      expect(cd.degree, closeTo(10.0, 1e-9));
    });

    test('负 1/4 圈（-π/2）从 亢10° 后退 15° → 角5°', () {
      final m = _threeConstellationModel();
      final cd = resolveAlignmentPointFromDrag(
        model: m,
        basePoint: ConstellationDegree(
            constellation: Enum28Constellations.Kang_Jin_Long, degree: 10),
        angleDeltaRadians: -pi / 2,
      );
      expect(cd.constellation, Enum28Constellations.Jiao_Mu_Jiao);
      expect(cd.degree, closeTo(5.0, 1e-9));
    });

    test('零增量 → 原对齐点不变', () {
      final m = _threeConstellationModel();
      final cd = resolveAlignmentPointFromDrag(
        model: m,
        basePoint: ConstellationDegree(
            constellation: Enum28Constellations.Kang_Jin_Long, degree: 7),
        angleDeltaRadians: 0.0,
      );
      expect(cd.constellation, Enum28Constellations.Kang_Jin_Long);
      expect(cd.degree, closeTo(7.0, 1e-9));
    });

    test('跨边界前进（从 氐25° +π/3=10° → 归一化 → 角5°）', () {
      final m = _threeConstellationModel();
      final cd = resolveAlignmentPointFromDrag(
        model: m,
        basePoint: ConstellationDegree(
            constellation: Enum28Constellations.Di_Tu_Lu, degree: 25),
        angleDeltaRadians: pi / 3, // 60/6 = 10°
      );
      expect(cd.constellation, Enum28Constellations.Jiao_Mu_Jiao);
      expect(cd.degree, closeTo(5.0, 1e-9));
    });
  });
}
