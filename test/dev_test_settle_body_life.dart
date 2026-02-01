import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/domain/services/an_shen_li_ming_service.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  double testSunangle = 211.02;
  group("立命", () {
    final testEnteredInfo = EnteredInfo(
      originalStar: StarDegree(
        star: EnumStars.Sun,
        degree: testSunangle,
      ),
      enterGongInfo: GongDegree(gong: EnumTwelveGong.Mao, degree: 1.02),
      enterInnInfo: ConstellationDegree(
        constellation: Enum28Constellations.Zhang_Yue_Lu,
        degree: 10,
      ),
    );

    test('定命宫 丁酉月 乙巳时 卯时立命，卯宫立命', () {
      // var res = SettleLifeBodyService.settleDownLifeGong(
      //     JiaZi.DING_YOU, JiaZi.YI_SI, testSunangle, false);
      var result2 = SettleLifeBodyService.settleLifeGong(
        testEnteredInfo,
        EnumTwelveGong.Mao,
        JiaZi.DING_YOU,
        JiaZi.YI_SI,
        false,
      );
      expect(result2, EnumTwelveGong.Mao);
    });
    test('定命宫 辛巳月 甲午时 卯时立命，午宫立命', () {
      // var res = SettleLifeBodyService.settleDownLifeGong(
      //     JiaZi.XIN_SI, JiaZi.JIA_WU, testSunangle, false);
      var result2 = SettleLifeBodyService.settleLifeGong(
        testEnteredInfo,
        EnumTwelveGong.Mao,
        JiaZi.XIN_SI,
        JiaZi.JIA_WU,
        false,
      );
      expect(result2, EnumTwelveGong.Wu);
    });
    test('定命宫 戊子月 壬午时 辰时立命，子宫立命', () {
      // var res = SettleLifeBodyService.settleDownLifeGong(
      //     JiaZi.WU_ZI, JiaZi.REN_WU, testSunangle, false, DiZhi.CHEN);
      var result2 = SettleLifeBodyService.settleLifeGong(
        testEnteredInfo,
        EnumTwelveGong.Chen,
        JiaZi.WU_ZI,
        JiaZi.REN_WU,
        false,
      );
      expect(result2, EnumTwelveGong.Zi);
    });
    test('定命宫 己亥月 己酉时 卯时立命，酉宫立命', () {
      // var res = SettleLifeBodyService.settleDownLifeGong(
      // JiaZi.JI_HAI, JiaZi.JI_YOU, testSunangle);
      var result2 = SettleLifeBodyService.settleLifeGong(
        testEnteredInfo,
        EnumTwelveGong.Mao,
        JiaZi.JI_HAI,
        JiaZi.JI_YOU,
        false,
      );
      expect(result2, EnumTwelveGong.You);
    });
    test('定命宫 庚戌月(太阳 211.02° 落宫卯宫1.02°) 乙未时 卯时立命，亥宫立命', () {
      /// 之前几种定命宫的方式是根据，得来，不是使用实际太阳的位置计算所得
      ///     // 每月太阳所在宫位
      //     // 子月在寅，丑月在丑
      //     // 寅月在子，卯月在亥
      //     // 辰月在戌，巳月在酉
      //     // 午月在申，未月在未
      //     // 申月在午，酉月在巳
      //     // 戌月在辰，亥月在卯
      // var res = SettleLifeBodyService.settleDownLifeGong(
      // JiaZi.GENG_XU, JiaZi.YI_WEI, testSunangle, true, DiZhi.MAO);
      var result2 = SettleLifeBodyService.settleLifeGong(
        testEnteredInfo,
        EnumTwelveGong.Mao,
        JiaZi.GENG_XU,
        JiaZi.YI_WEI,
        true,
      );
      expect(result2, EnumTwelveGong.Hai);
    });

    test('定命宫 庚戌月(太阳 211.02°) 乙未时 卯时立命，亥宫立命', () {
      /// 之前几种定命宫的方式是根据，得来，不是使用实际太阳的位置计算所得
      ///     // 每月太阳所在宫位
      //     // 子月在寅，丑月在丑
      //     // 寅月在子，卯月在亥
      //     // 辰月在戌，巳月在酉
      //     // 午月在申，未月在未
      //     // 申月在午，酉月在巳
      //     // 戌月在辰，亥月在卯
      var res = SettleLifeBodyService.settleDownLifeGong(
          JiaZi.GENG_XU, JiaZi.YI_WEI, testSunangle, true, DiZhi.MAO);
      expect(res, EnumTwelveGong.Hai);
    });

    test('太阳 211.02° 落宫卯宫', () {
      // var res = AnShenLiMingService.sunAtGong(DiZhi.XU.asMonthToken,211.02);
      var res = SettleLifeBodyService.sunEnterGongBySunsAngle(testSunangle);
      expect(res, EnumTwelveGong.Mao);
    });

    test('太阳 60° 落宫申宫', () {
      // var res = AnShenLiMingService.sunAtGong(DiZhi.XU.asMonthToken,211.02);
      var res = SettleLifeBodyService.sunEnterGongBySunsAngle(60);
      expect(res, EnumTwelveGong.Shen);
    });
  });
  group("安身", () {
    test("太阴落宫逆数至酉，安身，己巳时 身宫 为丑宫", () {
      var lunarInfo = MoonInfo(
        angle: 35,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(
            star: EnumStars.Moon,
            degree: 0.59,
          ),
          enterGongInfo: GongDegree(
            gong: EnumTwelveGong.You,
            degree: 15,
          ),
          enterInnInfo: ConstellationDegree(
            constellation: Enum28Constellations.Zhang_Yue_Lu,
            degree: 10,
          ),
        ),
        moonPhase: EnumMoonPhases.Can_Yue,
        // required bool isHidden
      );
      var result =
          SettleLifeBodyService.settleDownBodyGong(lunarInfo, JiaZi.JI_SI);

      var result2 = SettleLifeBodyService.settleBodyGong(
        lunarInfo.enterInfo,
        EnumTwelveGong.You,
        JiaZi.JI_SI,
      );
      expect(result, EnumTwelveGong.Chou);
    });
    test("太阴落宫逆数至酉，安身，壬午时 身宫为【申宫】", () {
      var lunarInfo = MoonInfo(
        angle: 171,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(
            star: EnumStars.Moon,
            degree: 0.59,
          ),
          enterGongInfo: GongDegree(
            gong: EnumTwelveGong.Si,
            degree: 21,
          ),
          enterInnInfo: ConstellationDegree(
            constellation: Enum28Constellations.Zhang_Yue_Lu,
            degree: 5.2,
          ),
          // required bool isHidden
        ),
        moonPhase: EnumMoonPhases.Can_Yue,
      );
      // var result =
      // SettleLifeBodyService.settleDownBodyGong(lunarInfo, JiaZi.REN_WU);
      var result2 = SettleLifeBodyService.settleBodyGong(
        lunarInfo.enterInfo,
        EnumTwelveGong.You,
        JiaZi.REN_WU,
      );
      // print(result.fullname);
      expect(result2, EnumTwelveGong.Shen);
    });
    test("太阴落宫逆数至酉，安身乙未时 身宫为【寅宫】", () {
      var lunarInfo = MoonInfo(
        angle: 330.59,
        enterInfo: EnteredInfo(
          originalStar: StarDegree(
            star: EnumStars.Moon,
            degree: 0.59,
          ),
          enterGongInfo: GongDegree(
            gong: EnumTwelveGong.Zi,
            degree: 0.59,
          ),
          enterInnInfo: ConstellationDegree(
            constellation: Enum28Constellations.Niu_Jin_Niu,
            degree: 0.59,
          ),
        ),
        moonPhase: EnumMoonPhases.Can_Yue,
        // required bool isHidden
      );
      // var result =
      // SettleLifeBodyService.settleDownBodyGong(lunarInfo, JiaZi.YI_WEI);
      var result2 = SettleLifeBodyService.settleBodyGong(
        lunarInfo.enterInfo,
        EnumTwelveGong.You,
        JiaZi.YI_WEI,
      );
      // print(result.fullname);
      expect(result2, EnumTwelveGong.Yin);
    });
  });
}
