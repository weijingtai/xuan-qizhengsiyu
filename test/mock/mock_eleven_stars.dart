import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';

class MockElevenStars {
  /// 创建测试用的完整星盘数据
  static Set<ElevenStarsInfo> createFullStarSet() {
    return {
      // 日月
      SunInfo(
        angle: 15.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Sun, degree: 15.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 15.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 5.5),
        ),
      ),

      MoonInfo(
        angle: 195.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Moon, degree: 195.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Wu, degree: 15.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Zhang_Yue_Lu, degree: 5.5),
        ),
        moonPhase: EnumMoonPhases.Full,
      ),

      // 五星
      FiveStarsInfo(
        star: EnumStars.Mercury,
        angle: 13.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Mercury, degree: 13.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 13.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 3.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 1.2,
      ),

      FiveStarsInfo(
        star: EnumStars.Venus,
        angle: 85.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Venus, degree: 85.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Si, degree: 25.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Wei_Yue_Yan, degree: 15.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.8,
      ),

      FiveStarsInfo(
        star: EnumStars.Mars,
        angle: 145.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Mars, degree: 145.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Wei, degree: 25.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Kui_Mu_Lang, degree: 5.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.5,
      ),

      FiveStarsInfo(
        star: EnumStars.Jupiter,
        angle: 265.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Jupiter, degree: 265.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Xu, degree: 25.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Xu_Ri_Shu, degree: 15.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.3,
      ),

      FiveStarsInfo(
        star: EnumStars.Saturn,
        angle: 325.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Saturn, degree: 325.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Hai, degree: 25.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Wei_Yue_Yan, degree: 15.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.1,
      ),

      // 四余
      FourSlaveStarInfo(
        star: EnumStars.Luo,
        angle: 16.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Luo, degree: 16.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 16.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6.5),
        ),
        walkingSpeed: 0.0055,
      ),

      FourSlaveStarInfo(
        star: EnumStars.Ji,
        angle: 196.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Ji, degree: 196.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Wu, degree: 16.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Zhang_Yue_Lu, degree: 6.5),
        ),
        walkingSpeed: 0.0055,
      ),

      FourSlaveStarInfo.qi(
        angle: 95.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Ji, degree: 95.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Si, degree: 5.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Wei_Yue_Yan, degree: 25.5),
        ),
      ),

      FourSlaveStarInfo.bei(
        angle: 275.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Ji, degree: 275.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Xu, degree: 5.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Xu_Ri_Shu, degree: 25.5),
        ),
      ),
    };
  }

  /// 创建同宫测试数据
  static Set<ElevenStarsInfo> createSameGongStars() {
    return {
      // 在辰宫的三颗星：日、水星、罗星
      SunInfo(
        angle: 15.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Sun, degree: 15.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 15.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 5.5),
        ),
      ),

      FiveStarsInfo(
        star: EnumStars.Mercury,
        angle: 13.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Mercury, degree: 13.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 13.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 3.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 1.2,
      ),

      FourSlaveStarInfo(
        star: EnumStars.Luo,
        angle: 16.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Luo, degree: 16.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 16.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6.5),
        ),
        walkingSpeed: 0.0055,
      ),
    };
  }

  /// 创建对宫测试数据（子午对冲）
  static Set<ElevenStarsInfo> createChongGongStars() {
    return {
      // 子宫的月亮
      MoonInfo(
        angle: 0.0,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Moon, degree: 0.0),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 15.0),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Xu_Ri_Shu, degree: 5.0),
        ),
        moonPhase: EnumMoonPhases.Full,
      ),

      // 午宫的火星
      FiveStarsInfo(
        star: EnumStars.Mars,
        angle: 180.0,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Mars, degree: 180.0),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Wu, degree: 15.0),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Zhang_Yue_Lu, degree: 5.0),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.5,
      ),
    };
  }

  /// 创建同宿测试数据
  static Set<ElevenStarsInfo> createSameStarInnStars() {
    return {
      // 同在昴日星宿的两颗星
      SunInfo(
        angle: 45.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Sun, degree: 45.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Yin, degree: 15.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 5.5),
        ),
      ),

      FiveStarsInfo(
        star: EnumStars.Venus,
        angle: 46.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Venus, degree: 46.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Yin, degree: 16.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Mao_Ri_Ji, degree: 6.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.8,
      ),
    };
  }

  /// 创建同经测试数据
  static Set<ElevenStarsInfo> createSameJingStars() {
    return {
      // 同属水经的两颗星（在不同星宿）
      FiveStarsInfo(
        star: EnumStars.Mercury,
        angle: 15.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Mercury, degree: 15.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 15.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Bi_Shui_Yu, degree: 5.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 1.2,
      ),

      FiveStarsInfo(
        star: EnumStars.Saturn,
        angle: 45.5,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Saturn, degree: 45.5),
          enterGongInfo: GongDegree(gong: EnumTwelveGong.Yin, degree: 15.5),
          enterInnInfo: ConstellationDegree(
              constellation: Enum28Constellations.Zhen_Shui_Yin, degree: 5.5),
        ),
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: 0.1,
      ),
    };
  }
}
