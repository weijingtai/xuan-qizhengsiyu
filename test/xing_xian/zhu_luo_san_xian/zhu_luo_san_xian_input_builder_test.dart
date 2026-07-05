import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';

/// Frederick B-law reference data:
/// lifePalace=酉, birthSect=day
/// Venus→寅, Moon→午, Mars→子
const _frederickStarPalaces = <EnumStars, EnumTwelveGong>{
  EnumStars.Sun: EnumTwelveGong.Xu,
  EnumStars.Moon: EnumTwelveGong.Wu,
  EnumStars.Mercury: EnumTwelveGong.Chou,
  EnumStars.Mars: EnumTwelveGong.Zi,
  EnumStars.Jupiter: EnumTwelveGong.Hai,
  EnumStars.Venus: EnumTwelveGong.Yin,
  EnumStars.Saturn: EnumTwelveGong.Chen,
};

/// Build a minimal [BasePanelModel] for testing [buildZhuLuoInputFromPanel].
///
/// Only the fields read by the builder are populated:
/// - `bodyLifeModel.lifeGong`
/// - `enteredGongMapper` entries for the seven zhu-luo stars
BasePanelModel _buildMinimalPanel({
  required EnumTwelveGong lifePalace,
  required Map<EnumStars, EnumTwelveGong> starPalaces,
}) {
  final enteredGongMapper = <EnumStars, EnteredInfo>{};
  for (final entry in starPalaces.entries) {
    enteredGongMapper[entry.key] = EnteredInfo(
      originalStar: StarDegree(star: entry.key, degree: 0),
      enterGongInfo: GongDegree(gong: entry.value, degree: 0),
      enterInnInfo: ConstellationDegree(
        constellation: Enum28Constellations.Lou_Jin_Gou,
        degree: 0,
      ),
    );
  }

  // Build dummy entries for required map keys on BasePanelModel
  final dummyThreshold = StarWalkingTypeThreshold(
    star: EnumStars.Sun,
    thresholdName: 'moira',
    maxSpeed: 1,
    maxRetrogradeThreshold: -1,
    retrogradeThreshold: -0.1,
    stayThreshold: 0.1,
    fastThreshold: null,
    slowThreshold: null,
  );

  return BasePanelModel(
    starAngleMapper: {
      for (final s in EnumStars.allStars)
        s: const StarAngleSpeed(angle: 0, speed: 0),
    },
    enteredGongMapper: enteredGongMapper,
    fiveStarWalkingTypeMapper: {
      for (final s in EnumStars.fiveStars)
        s: BaseFiveStarWalkingInfo(
          star: s,
          speed: 0,
          walkingType: FiveStarWalkingType.Normal,
          threshold: dummyThreshold,
        ),
    },
    bodyLifeModel: BodyLifeModel(
      lifeGongInfo: GongDegree(gong: lifePalace, degree: 0),
      lifeConstellationInfo: ConstellationDegree(
        constellation: Enum28Constellations.Lou_Jin_Gou,
        degree: 0,
      ),
      bodyGongInfo: GongDegree(gong: lifePalace, degree: 0),
      bodyConstellationInfo: ConstellationDegree(
        constellation: Enum28Constellations.Lou_Jin_Gou,
        degree: 0,
      ),
    ),
    twelveGongMapper: {},
    shenShaItemMapper: {},
    huaYaoItemMapper: {},
    twelveZhangShengGongMapper: {},
  );
}

void main() {
  group('zhuLuoRulerPalacesFromStarPalaces', () {
    test('maps seven stars to zhu-luo rulers', () {
      final result = zhuLuoRulerPalacesFromStarPalaces(_frederickStarPalaces);
      expect(result[ZhuLuoRuler.venus], EnumTwelveGong.Yin);
      expect(result[ZhuLuoRuler.moon], EnumTwelveGong.Wu);
      expect(result[ZhuLuoRuler.mars], EnumTwelveGong.Zi);
      expect(result[ZhuLuoRuler.sun], EnumTwelveGong.Xu);
      expect(result[ZhuLuoRuler.mercury], EnumTwelveGong.Chou);
      expect(result[ZhuLuoRuler.jupiter], EnumTwelveGong.Hai);
      expect(result[ZhuLuoRuler.saturn], EnumTwelveGong.Chen);
    });

    test('throws StateError when required star is missing', () {
      expect(
        () => zhuLuoRulerPalacesFromStarPalaces(
          {EnumStars.Sun: EnumTwelveGong.Wu},
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('throws StateError listing all missing stars', () {
      expect(
        () => zhuLuoRulerPalacesFromStarPalaces({
          EnumStars.Sun: EnumTwelveGong.Wu,
          EnumStars.Moon: EnumTwelveGong.Mao,
        }),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Missing star palaces'),
          ),
        ),
      );
    });

    test('returns unmodifiable map', () {
      final result = zhuLuoRulerPalacesFromStarPalaces(_frederickStarPalaces);
      expect(
        () => result[ZhuLuoRuler.sun] = EnumTwelveGong.Hai,
        throwsA(anything),
      );
    });
  });

  group('buildZhuLuoInputFromStarPalaces', () {
    test('Frederick B-law input has correct ruler palaces', () {
      final input = buildZhuLuoInputFromStarPalaces(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        starPalaces: _frederickStarPalaces,
        maxAge: 80,
        config: bridgeWithFallbackConfig,
      );
      expect(input.rulerPalaces[ZhuLuoRuler.mars], EnumTwelveGong.Zi);
      expect(input.rulerPalaces[ZhuLuoRuler.venus], EnumTwelveGong.Yin);
      expect(input.rulerPalaces[ZhuLuoRuler.moon], EnumTwelveGong.Wu);
      expect(input.lifePalace, EnumTwelveGong.You);
      expect(input.birthSect, BirthSect.day);
      expect(input.maxAge, 80);
      expect(input.config, bridgeWithFallbackConfig);
    });

    test('propagates StateError for incomplete star palaces', () {
      expect(
        () => buildZhuLuoInputFromStarPalaces(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          starPalaces: {EnumStars.Sun: EnumTwelveGong.Wu},
          maxAge: 80,
          config: bridgeWithFallbackConfig,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('buildZhuLuoInputFromPanel', () {
    test('Frederick panel yields correct ruler palaces', () {
      final panel = _buildMinimalPanel(
        lifePalace: EnumTwelveGong.You,
        starPalaces: _frederickStarPalaces,
      );
      final input = buildZhuLuoInputFromPanel(
        panel: panel,
        birthSect: BirthSect.day,
        maxAge: 80,
        config: bridgeWithFallbackConfig,
      );
      expect(input.rulerPalaces[ZhuLuoRuler.mars], EnumTwelveGong.Zi);
      expect(input.rulerPalaces[ZhuLuoRuler.venus], EnumTwelveGong.Yin);
      expect(input.rulerPalaces[ZhuLuoRuler.moon], EnumTwelveGong.Wu);
      expect(input.lifePalace, EnumTwelveGong.You);
    });

    test('panel with missing star throws StateError', () {
      final panel = _buildMinimalPanel(
        lifePalace: EnumTwelveGong.You,
        starPalaces: {EnumStars.Sun: EnumTwelveGong.Wu},
      );
      expect(
        () => buildZhuLuoInputFromPanel(
          panel: panel,
          birthSect: BirthSect.day,
          maxAge: 80,
          config: bridgeWithFallbackConfig,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
