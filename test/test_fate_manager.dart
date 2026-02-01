import 'package:common/enums.dart';
import 'package:common/models/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/fate_dong_wei_da_xian.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/managers/fate/dong_wei_child_xian_manager.dart';
import 'package:qizhengsiyu/domain/managers/fate/dong_wei_da_xian_manager.dart';
import 'package:qizhengsiyu/domain/managers/fate/dong_wei_fei_xian_manager.dart';
import 'package:qizhengsiyu/domain/managers/fate/dong_wei_month_xian_manager.dart';
import 'package:qizhengsiyu/domain/managers/fate/dong_wei_xiao_xian_manager.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  group("洞微大限（百六）", () {
    test("命限计算，现代方式 3°/12月 + 10年， 太阳入宫 5.5度", () {
      YearMonth res = DongWeiDaXianManager.getMingXianAddYears(5.5);
      expect(res.year, 1);
      expect(res.month, 10);
    });
    test("命限计算，现代方式 3°/12月 + 10年， 太阳入宫 15.9度", () {
      YearMonth res = DongWeiDaXianManager.getMingXianAddYears(15.9);
      expect(res.year, 5);
      expect(res.month, 3);
    });
    test("命限计算，古代方式， 太阳入宫巳火，命宫丑 10度", () {
      final res = DongWeiDaXianManager().calculate(
          DongWeiDaXianMingGongCountingType.Ancient,
          BodyLifeModel(
              lifeGongInfo: GongDegree(gong: EnumTwelveGong.Chou, degree: 10),
              lifeConstellationInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Yi_Huo_She, degree: 3),
              bodyGongInfo: GongDegree(gong: EnumTwelveGong.Si, degree: 10),
              bodyConstellationInfo: ConstellationDegree(
                  constellation: Enum28Constellations.Yi_Huo_She, degree: 3)));
      expect(res.daXianGongs.length, 12);
      expect(res.daXianGongs[0].destinyGong, EnumDestinyTwelveGong.Ming);
      expect(res.daXianGongs[0].gong, EnumTwelveGong.Chou);
      expect(res.daXianGongs[0].end.year, 13);

      expect(res.daXianGongs[1].destinyGong, EnumDestinyTwelveGong.XiangMao);
      expect(res.daXianGongs[1].gong, EnumTwelveGong.Yin);
      expect(res.daXianGongs[1].end.year, 23);

      expect(res.daXianGongs[2].destinyGong, EnumDestinyTwelveGong.FuDe);
      expect(res.daXianGongs[2].gong, EnumTwelveGong.Mao);
      expect(res.daXianGongs[2].end.year, 34);

      expect(res.daXianGongs[3].destinyGong, EnumDestinyTwelveGong.GuanLu);
      expect(res.daXianGongs[3].gong, EnumTwelveGong.Chen);
      expect(res.daXianGongs[3].end.year, 49);

      expect(res.daXianGongs[4].destinyGong, EnumDestinyTwelveGong.QianYi);
      expect(res.daXianGongs[4].gong, EnumTwelveGong.Si);
      expect(res.daXianGongs[4].end.year, 57);

      expect(res.daXianGongs[5].destinyGong, EnumDestinyTwelveGong.JiE);
      expect(res.daXianGongs[5].gong, EnumTwelveGong.Wu);
      expect(res.daXianGongs[5].end.year, 64);

      expect(res.daXianGongs[6].destinyGong, EnumDestinyTwelveGong.FuQi);
      expect(res.daXianGongs[6].gong, EnumTwelveGong.Wei);
      expect(res.daXianGongs[6].end.year, 75);

      expect(res.daXianGongs[7].destinyGong, EnumDestinyTwelveGong.NuPu);
      expect(res.daXianGongs[7].gong, EnumTwelveGong.Shen);
      expect(res.daXianGongs[7].end.year, 80);
    });
  });

  group("洞微小限", () {
    test("乙亥年生 命宫子 太岁在巳", () {
      final res = DongWeiXiaoXianManager.calculate(
          JiaZi.YI_HAI, EnumTwelveGong.Zi, DiZhi.SI);
      expect(res, EnumTwelveGong.Wu);
    });
    test("乙亥年生 命宫子 太岁在未", () {
      final res = DongWeiXiaoXianManager.calculate(
          JiaZi.YI_HAI, EnumTwelveGong.Zi, DiZhi.WEI);
      expect(res, EnumTwelveGong.Chen);
    });
    test("乙巳年生 命宫丑 太岁在亥", () {
      final res = DongWeiXiaoXianManager.calculate(
          JiaZi.YI_SI, EnumTwelveGong.Chou, DiZhi.HAI);
      expect(res, EnumTwelveGong.Wei);
    });
    test("辛酉年生 命宫卯 太岁在亥", () {
      final res = DongWeiXiaoXianManager.calculate(
          JiaZi.XIN_YOU, EnumTwelveGong.Mao, DiZhi.CHEN);
      expect(res, EnumTwelveGong.Shen);
    });
  });

  group("洞微月限", () {
    test("月限 小限申 月限子", () {
      final res = DongWeiMonthXianManager.calculate(
          EnumTwelveGong.Shen, JiaZi.XIN_MAO, JiaZi.YI_HAI);
      expect(res, EnumTwelveGong.Zi);
    });
  });
  group("洞微童限", () {
    test("童限计算", () {
      final res = DongWeiChildXianManager().calculate(YearMonth(15, 0));
      expect(res, DongWeiChildXianManager.childXianGongSeq);
    });
  });
  group("洞微飞限", () {
    test("飞限计算 命宫10年 阳宫", () {
      final res = DongWeiFeiXianManager().doCalculate(DaXianGong(
          order: 0,
          gong: EnumTwelveGong.Wu,
          start: YearMonth(1, 0),
          end: YearMonth(10, 0),
          totalYears: YearMonth(10, 0),
          destinyGong: EnumDestinyTwelveGong.Ming));
      expect(res.length, 10);

      // 第 1，2 年 本宫
      for (var i = 0; i < 2; i++) {
        expect(res[i].gong, EnumTwelveGong.Wu);
        expect(res[i].start.year, 1 + i,
            reason: res[0].start.toJson().toString());
        expect(res[i].start.month, 0, reason: res[0].start.toJson().toString());

        expect(res[i].end.year, 2 + i, reason: res[i].end.toJson().toString());
        expect(res[i].end.month, 0, reason: res[i].end.toJson().toString());
      }

      // 第 3，4 年 对宫
      for (var i = 2; i < 4; i++) {
        expect(res[i].gong, EnumTwelveGong.Zi);
        expect(res[i].start.year, 1 + i,
            reason: res[i].start.toJson().toString());
        expect(res[i].start.month, 0, reason: res[i].start.toJson().toString());

        expect(res[i].end.year, 2 + i, reason: res[i].end.toJson().toString());
        expect(res[i].end.month, 0, reason: res[i].end.toJson().toString());
      }

      // 第 5，6 年 三合宫
      expect(res[4].gong, EnumTwelveGong.Xu);
      expect(res[5].gong, EnumTwelveGong.Yin);

      expect(res[6].gong, EnumTwelveGong.Wu);
      expect(res[7].gong, EnumTwelveGong.Wu);

      // 第 7，8 年 本宫
      expect(res[8].gong, EnumTwelveGong.Zi);
      expect(res[9].gong, EnumTwelveGong.Zi);
    });
    test("飞限计算 相貌宫10年 阴宫", () {
      final res = DongWeiFeiXianManager().doCalculate(DaXianGong(
          order: 1,
          gong: EnumTwelveGong.Wei,
          start: YearMonth(11, 0),
          end: YearMonth(20, 0),
          totalYears: YearMonth(10, 0),
          destinyGong: EnumDestinyTwelveGong.XiangMao));
      expect(res.length, 10);

      // 第 1，2 年 本宫
      for (var i = 0; i < 2; i++) {
        expect(res[i].gong, EnumTwelveGong.Wei);
        expect(res[i].start.year, 11 + i,
            reason: res[0].start.toJson().toString());
        expect(res[i].start.month, 0, reason: res[0].start.toJson().toString());

        expect(res[i].end.year, 12 + i, reason: res[i].end.toJson().toString());
        expect(res[i].end.month, 0, reason: res[i].end.toJson().toString());
      }

      // 第 3，4 年 对宫
      for (var i = 2; i < 4; i++) {
        expect(res[i].gong, EnumTwelveGong.Chou);
        expect(res[i].start.year, 11 + i,
            reason: res[i].start.toJson().toString());
        expect(res[i].start.month, 0, reason: res[i].start.toJson().toString());

        expect(res[i].end.year, 12 + i, reason: res[i].end.toJson().toString());
        expect(res[i].end.month, 0, reason: res[i].end.toJson().toString());
      }

      // 第 5，6 年 三合宫
      expect(res[4].gong, EnumTwelveGong.Mao);
      expect(res[5].gong, EnumTwelveGong.Hai);

      expect(res[6].gong, EnumTwelveGong.Wei);
      expect(res[7].gong, EnumTwelveGong.Wei);

      // 第 7，8 年 本宫
      expect(res[8].gong, EnumTwelveGong.Chou);
      expect(res[9].gong, EnumTwelveGong.Chou);
    });
    test("飞限计算 福德宫11年 阳宫", () {
      // 福德宫 11年 （申 阳宫）
      // 21、22岁在申宫（本宫，即福德宫）
      // 23、24岁在寅宫（对宫，即男女宫）
      // 25岁在子宫（顺取三合，即夫妻宫，如图）
      // 26岁在辰宫（顺取三合，即兄弟宫）
      // 27、28岁在申宫
      // 29、30岁在寅宫
      // 31岁在子宫
      final res = DongWeiFeiXianManager().doCalculate(DaXianGong(
          order: 2,
          gong: EnumTwelveGong.Shen,
          start: YearMonth(21, 0),
          end: YearMonth(31, 0),
          totalYears: YearMonth(11, 0),
          destinyGong: EnumDestinyTwelveGong.FuDe));
      expect(res.length, 11);
      expect(res[0].gong, EnumTwelveGong.Shen);
      expect(res[1].gong, EnumTwelveGong.Shen);
      expect(res[2].gong, EnumTwelveGong.Yin);
      expect(res[10].gong, EnumTwelveGong.Zi);
      expect(res[10].start.year, 31);
      expect(res[10].end.year, 32);
    });

    test("奴仆宫 4.5年 丑阴宫", () {
      // 奴仆宫 4.5年（丑阴宫）
      // 73、74岁在丑宫
      // 75、76岁在未宫
      // 77岁上半年酉宫
      final res = DongWeiFeiXianManager().doCalculate(DaXianGong(
          order: 3,
          gong: EnumTwelveGong.Chou,
          start: YearMonth(73, 0),
          end: YearMonth(77, 6),
          totalYears: YearMonth(4, 6),
          destinyGong: EnumDestinyTwelveGong.NuPu));
      expect(res.length, 5);
      expect(res[0].gong, EnumTwelveGong.Chou);
      expect(res[1].gong, EnumTwelveGong.Chou);
      expect(res[2].gong, EnumTwelveGong.Wei);
      expect(res[3].gong, EnumTwelveGong.Wei);
      expect(res[4].gong, EnumTwelveGong.You);
      expect(res[4].start.year, 77);
      expect(res[4].start.month, 0);
      expect(res[4].end.year, 77);
      expect(res[4].end.month, 6);
    });

    test("男女宫 4.5年 寅阳宫", () {
      // 男女宫 4.5年（寅阳宫）
      // 77岁下半年寅宫
      // 78岁在寅宫
      // 79岁上半年在寅宫、下半年在申宫
      // 80岁在申宫
      // 81岁上半年在申宫、下半年在午宫
      final res = DongWeiFeiXianManager().doCalculate(DaXianGong(
          order: 4,
          gong: EnumTwelveGong.Yin,
          start: YearMonth(77, 6),
          end: YearMonth(81, 6),
          totalYears: YearMonth(4, 6),
          destinyGong: EnumDestinyTwelveGong.NuPu));
      expect(res.length, 5);
      expect(res[0].gong, EnumTwelveGong.Yin);
      expect(res[0].start.year, 77);
      expect(res[0].start.month, 6);
      expect(res[0].end.year, 78);
      expect(res[0].end.month, 6);

      expect(res[1].gong, EnumTwelveGong.Yin);
      expect(res[1].start.year, 78);
      expect(res[1].start.month, 6);
      expect(res[1].end.year, 79);
      expect(res[1].end.month, 6);

      expect(res[2].gong, EnumTwelveGong.Shen);
      expect(res[2].start.year, 79);
      expect(res[2].start.month, 6);
      expect(res[2].end.year, 80);
      expect(res[2].end.month, 6);

      expect(res[3].gong, EnumTwelveGong.Shen);
      expect(res[3].start.year, 80);
      expect(res[3].start.month, 6);
      expect(res[3].end.year, 81);
      expect(res[3].end.month, 6);

      expect(res[4].gong, EnumTwelveGong.Wu);
      expect(res[4].start.year, 81);
      expect(res[4].start.month, 6);
      expect(res[4].end.year, 82);
      expect(res[4].end.month, 0);
    });
  });
}
