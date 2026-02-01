import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/star_to_star_relationship_model.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import '../mock/mock_eleven_stars.dart';

void main() {
  group('StarToStarRelationshipModel Tests', () {
    // test('验证星体数量检查', () {
    //   // 测试星体数量不足的情况
    //   expect(
    //     () => StarToStarRelationshipModel.create(Set()),
    //     throwsArgumentError,
    //   );

    //   // 测试正确的星体数量
    //   var fullStars = MockElevenStars.createFullStarSet();
    //   expect(
    //     () => StarToStarRelationshipModel.create(fullStars),
    //     returnsNormally,
    //   );
    // });

    group('同宫关系测试', () {
      test('验证同宫星体关系', () {
        var stars = MockElevenStars.createSameGongStars();
        var model = StarToStarRelationshipModel.create(stars);

        // 验证辰宫的三颗星
        var chenGongStars = model.sameGongMap[EnumTwelveGong.Chen];
        expect(chenGongStars, isNotNull);
        expect(chenGongStars!.length, equals(3));

        // 验证星体类型
        expect(
          chenGongStars.any((s) => s.star == EnumStars.Sun),
          isTrue,
          reason: '辰宫应包含太阳',
        );
        expect(
          chenGongStars.any((s) => s.star == EnumStars.Mercury),
          isTrue,
          reason: '辰宫应包含水星',
        );
        expect(
          chenGongStars.any((s) => s.star == EnumStars.Luo),
          isTrue,
          reason: '辰宫应包含罗星',
        );
      });

      test('验证余奴犯主现象', () {
        var stars = MockElevenStars.createSameGongStars();
        var model = StarToStarRelationshipModel.create(stars);

        var chenGongStars = model.sameGongMap[EnumTwelveGong.Chen]!;
        var mainStar = chenGongStars.firstWhere((s) => !s.isSlave);
        var yuNuStar = chenGongStars.firstWhere((s) => s.isSlave);

        expect(
            mainStar.enteredGongDegree, lessThan(yuNuStar.enteredGongDegree));
      });

      test('Some stars in the same gong', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.sameGongMap.containsKey(EnumTwelveGong.Zi), true);
        expect(model.sameGongMap[EnumTwelveGong.Zi]!.length, 2);
      });

      test('All stars in different gongs', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.sameGongMap.isEmpty, true);
      });
    });

    group('对宫关系测试', () {
      test('验证对宫星体关系', () {
        var stars = MockElevenStars.createChongGongStars();
        var model = StarToStarRelationshipModel.create(stars);

        // 验证子午对冲
        var ziWuChong = DiZhiChong.ZI_WU;
        var chongMap = model.chongGongSet[ziWuChong];

        expect(chongMap, isNotNull);
        expect(chongMap![EnumTwelveGong.Zi], isNotNull);
        expect(chongMap[EnumTwelveGong.Wu], isNotNull);

        // 验证对冲星体
        var ziStars = chongMap[EnumTwelveGong.Zi]!;
        var wuStars = chongMap[EnumTwelveGong.Wu]!;

        expect(
          ziStars.any((s) => s.star == EnumStars.Moon),
          isTrue,
          reason: '子宫应包含月亮',
        );
        expect(
          wuStars.any((s) => s.star == EnumStars.Mars),
          isTrue,
          reason: '午宫应包含火星',
        );
      });
      test('Some stars in chong gong', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Moon,
            angle: 180,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Moon, degree: 180),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Wu, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Fang_Ri_Tu, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Secondary,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.chongGongSet.containsKey(DiZhiChong.ZI_WU), true);
        expect(
            model.chongGongSet[DiZhiChong.ZI_WU]!
                .containsKey(EnumTwelveGong.Zi),
            true);
        expect(
            model.chongGongSet[DiZhiChong.ZI_WU]!
                .containsKey(EnumTwelveGong.Wu),
            true);
      });

      test('All stars without chong gong relationship', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.chongGongSet.isEmpty, true);
      });
    });

    group('同宿关系测试', () {
      test('验证同宿星体关系', () {
        var stars = MockElevenStars.createSameStarInnStars();
        var model = StarToStarRelationshipModel.create(stars);

        // 验证昴日星宿的星体
        var maoStars = model.sameStarInnMap[Enum28Constellations.Mao_Ri_Ji];
        expect(maoStars, isNotNull);
        expect(maoStars!.length, equals(2));

        // 验证星体类型
        expect(
          maoStars.any((s) => s.star == EnumStars.Sun),
          isTrue,
          reason: '昴日星宿应包含太阳',
        );
        expect(
          maoStars.any((s) => s.star == EnumStars.Venus),
          isTrue,
          reason: '昴日星宿应包含金星',
        );
      });
      test('Some stars in the same star inn', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(
            model.sameStarInnMap.containsKey(Enum28Constellations.Lou_Jin_Gou),
            true);
        expect(
            model.sameStarInnMap[Enum28Constellations.Lou_Jin_Gou]!.length, 2);
      });

      test('All stars in different star inns', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.sameStarInnMap.isEmpty, true);
      });
    });

    group('同经关系测试', () {
      test('验证同经星体关系', () {
        var stars = MockElevenStars.createSameJingStars();
        var model = StarToStarRelationshipModel.create(stars);

        // 验证水经星宿的星体
        var waterJing = model.sameJingMap[EnumStars.Mercury];
        expect(waterJing, isNotNull);

        // 验证不同星宿但同属性的情况
        expect(waterJing!.length, greaterThan(1));

        // 验证具体星宿中的星体
        var biStars = waterJing[Enum28Constellations.Bi_Shui_Yu];
        var kuiStars = waterJing[Enum28Constellations.Zhen_Shui_Yin];

        expect(biStars!.any((s) => s.star == EnumStars.Mercury), isTrue);
        expect(kuiStars!.any((s) => s.star == EnumStars.Saturn), isTrue);
      });
      test('所有11星体', () {
        var stars = MockElevenStars.createFullStarSet();
        var model = StarToStarRelationshipModel.create(stars);

        // 验证日经星宿的星体
        var sunJing = model.sameJingMap[EnumStars.Sun];
        expect(sunJing, isNotNull);
        // 验证不同星宿但同属性的情况
        expect(sunJing!.length, greaterThan(1));

        // 验证具体星宿中的星体
        var maoStars = sunJing[Enum28Constellations.Mao_Ri_Ji];
        var xuStars = sunJing[Enum28Constellations.Xu_Ri_Shu];

        expect(
            maoStars!.any((s) => s.enteredStarInn.sevenZheng == EnumStars.Sun),
            isTrue);
        expect(
            xuStars!.any((s) => s.enteredStarInn.sevenZheng == EnumStars.Sun),
            isTrue);

        var moonJing = model.sameJingMap[EnumStars.Moon];
        expect(moonJing, isNotNull);
        // 验证不同星宿但同属性的情况
        expect(moonJing!.length, greaterThan(1));

        // 验证具体星宿中的星体
        var zhangStars = moonJing[Enum28Constellations.Zhang_Yue_Lu];
        var weiStars = moonJing[Enum28Constellations.Wei_Yue_Yan];

        expect(
            zhangStars!
                .any((s) => s.enteredStarInn.sevenZheng == EnumStars.Moon),
            isTrue);
        expect(
            weiStars!.any((s) => s.enteredStarInn.sevenZheng == EnumStars.Moon),
            isTrue);
      });
      test('Some stars in the same jing', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Xing_Ri_Ma, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.sameJingMap.containsKey(EnumStars.Sun), true);
        expect(
            model.sameJingMap[EnumStars.Sun]!
                .containsKey(Enum28Constellations.Mao_Ri_Ji),
            true);
        expect(
            model.sameJingMap[EnumStars.Sun]!
                .containsKey(Enum28Constellations.Xing_Ri_Ma),
            true);
      });

      test('All stars in different jings', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Zi_Huo_Hou, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.sameJingMap.isEmpty, true);
      });
    });

    group('同络关系测试', () {
      test('验证同络星体关系', () {
        var stars = MockElevenStars.createFullStarSet();
        var model =
            StarToStarRelationshipModel.create(stars, sameLuoDegreeRange: 3.0);

        expect(model.sameLuoSet, isNotEmpty);

        // 验证同络集合中的度数关系
        for (var luoSet in model.sameLuoSet) {
          var firstStar = luoSet.first;
          for (var star in luoSet) {
            if (star != firstStar) {
              var degreeDiff =
                  (star.enteredGongDegree - firstStar.enteredGongDegree).abs();
              expect(degreeDiff, lessThanOrEqualTo(3.0));
            }
          }
        }
      });
      test('Narrow sense same luo', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Mercury,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mercury, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Venus,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Venus, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Xing_Ri_Ma, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.sameLuoSet.isNotEmpty, true);
      });

      test('Change sameLuoDegreeRange', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model1 =
            StarToStarRelationshipModel.create(starsSet, sameLuoDegreeRange: 1);
        var model2 =
            StarToStarRelationshipModel.create(starsSet, sameLuoDegreeRange: 3);
        expect(model1.sameLuoSet.length != model2.sameLuoSet.length, true);
      });
    });

    group('三方关系测试', () {
      test('验证三合局关系 水局没有 火局有', () {
        var stars = MockElevenStars.createFullStarSet();
        var model = StarToStarRelationshipModel.create(stars);

        // 验证申子辰水局
        var waterHe = DiZhiSanHe.Water;
        var waterHeMap = model.threeHeGongMap[waterHe];
        expect(waterHeMap, isNull);

        var fireHe = DiZhiSanHe.Fire;
        var fireHeMap = model.threeHeGongMap[fireHe];
        expect(fireHeMap, isNotNull);

        if (fireHeMap != null) {
          // 验证三合宫位中的星体
          var yinStars = fireHeMap[EnumTwelveGong.Yin];
          var wuStars = fireHeMap[EnumTwelveGong.Wu];
          var xuStars = fireHeMap[EnumTwelveGong.Xu];

          expect(yinStars?.isEmpty ?? true, isTrue);
          expect(wuStars?.isEmpty ?? true, isFalse);
          expect(xuStars?.isEmpty ?? true, isFalse);
        }
      });
      test('Some stars in three he gong', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Saturn,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Saturn, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Shen, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Shen_Shui_Yuan,
                  degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 120,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 120),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Secondary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Moon,
            angle: 240,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Moon, degree: 240),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 15),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Jing_Mu_Han, degree: 8),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.threeHeGongMap.containsKey(DiZhiSanHe.Water), true);
        expect(
            model.threeHeGongMap[DiZhiSanHe.Water]!
                .containsKey(EnumTwelveGong.Shen),
            true);
        expect(
            model.threeHeGongMap[DiZhiSanHe.Water]!
                .containsKey(EnumTwelveGong.Zi),
            true);
        expect(
            model.threeHeGongMap[DiZhiSanHe.Water]!
                .containsKey(EnumTwelveGong.Chen),
            true);
      });

      test('All stars without three he gong relationship', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.threeHeGongMap.isEmpty, true);
      });
    });

    group('四正关系测试', () {
      test('验证四正关系 四仲没有 ', () {
        var stars = MockElevenStars.createFullStarSet();
        var model = StarToStarRelationshipModel.create(stars);

        // 验证子午卯酉四正
        var ziZheng = DiZhiFourZheng.getBySingleDiZhi(DiZhi.ZI);
        var ziZhengMap = model.fourZhengMap[ziZheng];
        expect(ziZhengMap, isNull);
      });
      test('Some stars in four zheng', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Sun,
            angle: 0,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Sun, degree: 0),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Lou_Jin_Gou, degree: 5),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Primary,
          ),
          ElevenStarsInfo(
            star: EnumStars.Moon,
            angle: 90,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Moon, degree: 90),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Mao, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Secondary,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.fourZhengMap.isNotEmpty, true);
        // 可以进一步验证具体的四正宫位和星体集合
      });

      test('All stars without four zheng relationship', () {
        Set<ElevenStarsInfo> starsSet = {
          ElevenStarsInfo(
            star: EnumStars.Mars,
            angle: 10,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Mars, degree: 10),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 12),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Normal,
          ),
          ElevenStarsInfo(
            star: EnumStars.Jupiter,
            angle: 20,
            enterInfo: EnteredInfo(
              originalStar: StarDegree(star: EnumStars.Jupiter, degree: 20),
              enterGongInfo: GongDegree(gong: EnumTwelveGong.Yin, degree: 15),
              enterInnInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Wei_Tu_Zhi, degree: 8),
            ),
            fiveStarWalkingType: FiveStarWalkingType.Normal,
            walkingSpeed: 1,
            priority: EnumStarsPriority.Lowest,
          ),
        };
        var model = StarToStarRelationshipModel.create(starsSet);
        expect(model.fourZhengMap.isEmpty, true);
      });
    });

    test('性能测试', () {
      var stars = MockElevenStars.createFullStarSet();

      // 测量模型创建时间
      var startTime = DateTime.now();
      var model = StarToStarRelationshipModel.create(stars);
      var endTime = DateTime.now();

      var duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(1000));
    });
  });
}
