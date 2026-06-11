import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart';
import 'package:qizhengsiyu/domain/managers/fate/zhu_luo_san_xian_manager.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';

/// Frederick B-law reference data (all 7 stars).
const _frederickStarPalaces = <EnumStars, EnumTwelveGong>{
  EnumStars.Sun: EnumTwelveGong.Xu,
  EnumStars.Moon: EnumTwelveGong.Wu,
  EnumStars.Mercury: EnumTwelveGong.Chou,
  EnumStars.Mars: EnumTwelveGong.Zi,
  EnumStars.Jupiter: EnumTwelveGong.Hai,
  EnumStars.Venus: EnumTwelveGong.Yin,
  EnumStars.Saturn: EnumTwelveGong.Chen,
};

const _frederickRulerPalaces = <ZhuLuoRuler, EnumTwelveGong>{
  ZhuLuoRuler.venus: EnumTwelveGong.Yin,
  ZhuLuoRuler.moon: EnumTwelveGong.Wu,
  ZhuLuoRuler.mars: EnumTwelveGong.Zi,
};

BasePanelModel _buildFrederickPanel() {
  final enteredGongMapper = <EnumStars, EnteredInfo>{};
  for (final entry in _frederickStarPalaces.entries) {
    enteredGongMapper[entry.key] = EnteredInfo(
      originalStar: StarDegree(star: entry.key, degree: 0),
      enterGongInfo: GongDegree(gong: entry.value, degree: 0),
      enterInnInfo: ConstellationDegree(
        constellation: Enum28Constellations.Lou_Jin_Gou,
        degree: 0,
      ),
    );
  }

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
      lifeGongInfo: GongDegree(gong: EnumTwelveGong.You, degree: 0),
      lifeConstellationInfo: ConstellationDegree(
        constellation: Enum28Constellations.Lou_Jin_Gou,
        degree: 0,
      ),
      bodyGongInfo: GongDegree(gong: EnumTwelveGong.You, degree: 0),
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
  late ZhuLuoSanXianManager manager;

  setUp(() {
    manager = ZhuLuoSanXianManager();
  });

  group('calculateFromRulerPalaces', () {
    test('delegates to calculator and returns results', () {
      final results = manager.calculateFromRulerPalaces(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        rulerPalaces: _frederickRulerPalaces,
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      expect(results, isNotEmpty);
      expect(results.firstWhere((r) => r.age == 61).palace, EnumTwelveGong.Wu);
      expect(results.firstWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);
    });
  });

  group('calculateFromStarPalaces', () {
    test('Frederick age 61 → Wu', () {
      final results = manager.calculateFromStarPalaces(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        starPalaces: _frederickStarPalaces,
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      expect(results.firstWhere((r) => r.age == 61).palace, EnumTwelveGong.Wu);
    });

    test('Frederick age 75 → Shen', () {
      final results = manager.calculateFromStarPalaces(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        starPalaces: _frederickStarPalaces,
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      expect(results.firstWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);
    });

    test('throws StateError for incomplete star palaces', () {
      expect(
        () => manager.calculateFromStarPalaces(
          lifePalace: EnumTwelveGong.You,
          birthSect: BirthSect.day,
          starPalaces: {EnumStars.Sun: EnumTwelveGong.Wu},
          maxAge: 80,
          config: directAnnualWithBridgeConfig,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('calculateFromPanel', () {
    test('FrederickPanel age 75 → Shen', () {
      final panel = _buildFrederickPanel();
      final results = manager.calculateFromPanel(
        panel: panel,
        birthSect: BirthSect.day,
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      expect(results.firstWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);
    });

    test('FrederickPanel age 61 → Wu', () {
      final panel = _buildFrederickPanel();
      final results = manager.calculateFromPanel(
        panel: panel,
        birthSect: BirthSect.day,
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      expect(results.firstWhere((r) => r.age == 61).palace, EnumTwelveGong.Wu);
    });
  });
}
