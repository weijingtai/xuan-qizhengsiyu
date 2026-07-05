import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_palace_math.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_spiral_mapper.dart';

void main() {
  group("Base tables and helpers", () {
    test("triplicity limit rulers", () {
      expect(zhuLuoLimitRulers(EnumTwelveGong.You, BirthSect.day), [
        ZhuLuoRuler.venus,
        ZhuLuoRuler.moon,
        ZhuLuoRuler.mars,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.You, BirthSect.night), [
        ZhuLuoRuler.moon,
        ZhuLuoRuler.venus,
        ZhuLuoRuler.mars,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.Zi, BirthSect.day), [
        ZhuLuoRuler.saturn,
        ZhuLuoRuler.mercury,
        ZhuLuoRuler.jupiter,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.Yin, BirthSect.day), [
        ZhuLuoRuler.sun,
        ZhuLuoRuler.jupiter,
        ZhuLuoRuler.saturn,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.Hai, BirthSect.day), [
        ZhuLuoRuler.venus,
        ZhuLuoRuler.mars,
        ZhuLuoRuler.moon,
      ]);
    });

    test("star numbers", () {
      expect(rulerNumber(ZhuLuoRuler.moon), 1);
      expect(rulerNumber(ZhuLuoRuler.mercury), 1);
      expect(rulerNumber(ZhuLuoRuler.sun), 2);
      expect(rulerNumber(ZhuLuoRuler.mars), 2);
      expect(rulerNumber(ZhuLuoRuler.jupiter), 3);
      expect(rulerNumber(ZhuLuoRuler.venus), 4);
      expect(rulerNumber(ZhuLuoRuler.saturn), 5);
    });

    test("ruler duration", () {
      expect(rulerDuration(ZhuLuoRuler.moon), 24);
      expect(rulerDuration(ZhuLuoRuler.mercury), 24);
      expect(rulerDuration(ZhuLuoRuler.sun), 28);
      expect(rulerDuration(ZhuLuoRuler.mars), 28);
      expect(rulerDuration(ZhuLuoRuler.jupiter), 30);
      expect(rulerDuration(ZhuLuoRuler.venus), 26);
      expect(rulerDuration(ZhuLuoRuler.saturn), 26);
    });

    test("palace move and distance math", () {
      expect(movePalace(EnumTwelveGong.Si, -2), EnumTwelveGong.Mao);
      expect(movePalace(EnumTwelveGong.Mao, -2), EnumTwelveGong.Chou);
      expect(movePalace(EnumTwelveGong.Yin, 1), EnumTwelveGong.Mao);
      expect(forwardDistance(EnumTwelveGong.Wei, EnumTwelveGong.Zi), 5);
    });
  });

  group("Doc B §7.1 金标: 初限·土起巳 (doc1 原文)", () {
    test("Saturn in Si: N=5, T=26, p0=巳", () {
      // 土星起巳，停留5年，标准总年限26年
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.Zi,
        birthSect: BirthSect.day,
        rulerPalaces: {ZhuLuoRuler.saturn: EnumTwelveGong.Si},
        maxAge: 30,
        config: classicForwardUntilTargetConfig,
      );
      final results = calculateZhuLuoSanXian(input);
      
      // 断言 1–5 守巳
      expect(results.firstWhere((r) => r.age == 1).palace, EnumTwelveGong.Si);
      expect(results.firstWhere((r) => r.age == 2).palace, EnumTwelveGong.Si);
      expect(results.firstWhere((r) => r.age == 3).palace, EnumTwelveGong.Si);
      expect(results.firstWhere((r) => r.age == 4).palace, EnumTwelveGong.Si);
      expect(results.firstWhere((r) => r.age == 5).palace, EnumTwelveGong.Si);
      
      // 断言 age 15 → 卯 (6午,7未,…,15卯)
      // 从第6年开始顺行：6→午(6), 7→未(7), 8→申(8), 9→酉(9), 10→戌(10),
      // 11→亥(11), 12→子(0), 13→丑(1), 14→寅(2), 15→卯(3)
      expect(results.firstWhere((r) => r.age == 15).palace, EnumTwelveGong.Mao);
      
      // 断言 age 16 → 辰 (继续顺行)
      expect(results.firstWhere((r) => r.age == 16).palace, EnumTwelveGong.Chen);
      
      // 断言 age 25 → 丑
      expect(results.firstWhere((r) => r.age == 25).palace, EnumTwelveGong.Chou);
      
      // 断言 age 26 → 寅
      expect(results.firstWhere((r) => r.age == 26).palace, EnumTwelveGong.Yin);
      
      // 断言 phase 标记
      expect(results.firstWhere((r) => r.age == 1).phase, "hold");
      expect(results.firstWhere((r) => r.age == 6).phase, "direct");
      expect(results.firstWhere((r) => r.age == 15).phase, "direct");
    });
  });

  group("Doc B §7.3 限主星定取", () {
    test("四局 × 昼夜共 8 组", () {
      // 寅午戌 局
      expect(zhuLuoLimitRulers(EnumTwelveGong.Yin, BirthSect.day), [
        ZhuLuoRuler.sun, ZhuLuoRuler.jupiter, ZhuLuoRuler.saturn,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.Yin, BirthSect.night), [
        ZhuLuoRuler.jupiter, ZhuLuoRuler.sun, ZhuLuoRuler.saturn,
      ]);
      
      // 亥卯未 局
      expect(zhuLuoLimitRulers(EnumTwelveGong.Hai, BirthSect.day), [
        ZhuLuoRuler.venus, ZhuLuoRuler.mars, ZhuLuoRuler.moon,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.Hai, BirthSect.night), [
        ZhuLuoRuler.mars, ZhuLuoRuler.venus, ZhuLuoRuler.moon,
      ]);
      
      // 申子辰 局
      expect(zhuLuoLimitRulers(EnumTwelveGong.Zi, BirthSect.day), [
        ZhuLuoRuler.saturn, ZhuLuoRuler.mercury, ZhuLuoRuler.jupiter,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.Zi, BirthSect.night), [
        ZhuLuoRuler.mercury, ZhuLuoRuler.saturn, ZhuLuoRuler.jupiter,
      ]);
      
      // 巳酉丑 局
      expect(zhuLuoLimitRulers(EnumTwelveGong.You, BirthSect.day), [
        ZhuLuoRuler.venus, ZhuLuoRuler.moon, ZhuLuoRuler.mars,
      ]);
      expect(zhuLuoLimitRulers(EnumTwelveGong.You, BirthSect.night), [
        ZhuLuoRuler.moon, ZhuLuoRuler.venus, ZhuLuoRuler.mars,
      ]);
    });
  });

  group("Doc B §7.4 恒等式: 零年 = T − N − 20", () {
    test("随机星体，断言零年年数 = T−N−20", () {
      // 太阴: T=24, N=1, 零年=24-1-20=3
      expect(rulerDuration(ZhuLuoRuler.moon) - rulerNumber(ZhuLuoRuler.moon) - 20, 3);
      // 水星: T=24, N=1, 零年=24-1-20=3
      expect(rulerDuration(ZhuLuoRuler.mercury) - rulerNumber(ZhuLuoRuler.mercury) - 20, 3);
      // 太阳: T=28, N=2, 零年=28-2-20=6
      expect(rulerDuration(ZhuLuoRuler.sun) - rulerNumber(ZhuLuoRuler.sun) - 20, 6);
      // 火星: T=28, N=2, 零年=28-2-20=6
      expect(rulerDuration(ZhuLuoRuler.mars) - rulerNumber(ZhuLuoRuler.mars) - 20, 6);
      // 木星: T=30, N=3, 零年=30-3-20=7
      expect(rulerDuration(ZhuLuoRuler.jupiter) - rulerNumber(ZhuLuoRuler.jupiter) - 20, 7);
      // 金星: T=26, N=4, 零年=26-4-20=2
      expect(rulerDuration(ZhuLuoRuler.venus) - rulerNumber(ZhuLuoRuler.venus) - 20, 2);
      // 土星: T=26, N=5, 零年=26-5-20=1
      expect(rulerDuration(ZhuLuoRuler.saturn) - rulerNumber(ZhuLuoRuler.saturn) - 20, 1);
    });
  });

  group("Doc B §7.2 四方案分歧用例", () {
    // 构造一个 pEnd ≠ pNext 且"已过 pNext"的盘
    // 土星起巳(N=5,T=26)，水星起子(N=1,T=24)
    // 初限土星走26年，从巳顺行：pEnd = (5 + 26-5) % 12 = 26 % 12 = 2 (寅)
    // 中限水星起子，pNext = 子(0)
    // pEnd=2(寅) 已过 pNext=0(子)：寅→子顺行需 10 步

    test("方案1: 候星逐宫延交法 - 已过pNext则继续顺行", () {
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.Zi,
        birthSect: BirthSect.day,
        rulerPalaces: {
          ZhuLuoRuler.saturn: EnumTwelveGong.Si,
          ZhuLuoRuler.mercury: EnumTwelveGong.Zi,
          ZhuLuoRuler.jupiter: EnumTwelveGong.Mao,
        },
        maxAge: 60,
        config: classicForwardUntilTargetConfig,
      );
      final results = calculateZhuLuoSanXian(input);

      // 初限26年：1-5守巳，6-26顺行
      // age 26: palace = movePalace(Si, 26-5) = movePalace(Si, 21) = Yin(寅)
      expect(results.firstWhere((r) => r.age == 26).palace, EnumTwelveGong.Yin);

      // 方案1：pEnd=寅 已过 pNext=子，继续顺行
      // age 27: 卯(3), age 28: 辰(4), ... age 36: 子(0)
      // 找到子(0)时交限，即 age 36
      expect(results.firstWhere((r) => r.age == 36).palace, EnumTwelveGong.Zi);
      expect(results.firstWhere((r) => r.age == 36).isTransitionYear, true);
    });

    test("方案2: 年限强制切换法 - 到期直接强制换限", () {
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.Zi,
        birthSect: BirthSect.day,
        rulerPalaces: {
          ZhuLuoRuler.saturn: EnumTwelveGong.Si,
          ZhuLuoRuler.mercury: EnumTwelveGong.Zi,
          ZhuLuoRuler.jupiter: EnumTwelveGong.Mao,
        },
        maxAge: 60,
        config: forceCutConfig,
      );
      final results = calculateZhuLuoSanXian(input);

      // 方案2：age 26 处强制截断
      expect(results.firstWhere((r) => r.age == 26).phase, "forcedCut");
      expect(results.firstWhere((r) => r.age == 26).isTransitionYear, true);
    });

    test("方案3: 折返补救交限法 - 已过pNext则逆行折返", () {
      // 构造一个"已过pNext"的场景：
      // 土星起巳(N=5,T=26)，水星本命宫亥(11)
      // age 26: movePalace(Si, 21) = 寅(2)
      // pNext = 亥(11)，pEnd = 寅(2)
      // forwardDistance(寅, 亥) = (11-2+12)%12 = 9
      // 9 > 6，已过pNext，需要逆行折返
      // retraceDist = (12-9)%12 = 3
      // 从寅(2)折返3步到亥(11)
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.Zi,
        birthSect: BirthSect.day,
        rulerPalaces: {
          ZhuLuoRuler.saturn: EnumTwelveGong.Si,
          ZhuLuoRuler.mercury: EnumTwelveGong.Hai,
          ZhuLuoRuler.jupiter: EnumTwelveGong.Mao,
        },
        maxAge: 60,
        config: retraceConfig,
      );
      final results = calculateZhuLuoSanXian(input);

      // 方案3：age 26 在寅(2)宫，已过 pNext=亥(11)，逆行折返3步到亥
      expect(results.firstWhere((r) => r.age == 26).palace, EnumTwelveGong.Hai);
      expect(results.firstWhere((r) => r.age == 26).phase, "zheFan");
      expect(results.firstWhere((r) => r.age == 26).isTransitionYear, true);
    });

    test("方案4: 补桥年限双轨交限法 - 满足补桥公式", () {
      // 土星起巳(N=5,T=26)，木星起卯(N=3,T=30)
      // 初限土星：pEnd = movePalace(Si, 26-5) = Yin(寅)
      // pNext = Mao(卯)
      // forwardDistance(Yin, Mao) = 1
      // m = rulerNumber(jupiter) = 3
      // R = T - (T-N) = 26 - 21 = 5
      // 补桥条件：d * m == R → 1 * 3 == 5 → false
      // 所以走兜底强制切换

      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.Zi,
        birthSect: BirthSect.day,
        rulerPalaces: {
          ZhuLuoRuler.saturn: EnumTwelveGong.Si,
          ZhuLuoRuler.jupiter: EnumTwelveGong.Mao,
          ZhuLuoRuler.mercury: EnumTwelveGong.Mao,
        },
        maxAge: 60,
        config: bridgeWithFallbackConfig,
      );
      final results = calculateZhuLuoSanXian(input);

      // 不满足补桥条件，走兜底强制切换
      expect(results.firstWhere((r) => r.age == 26).phase, "forcedCut");
      expect(results.firstWhere((r) => r.age == 26).isTransitionYear, true);
    });
  });

  group("Doc B §7.5 串接", () {
    test("中限 startAge = 初限交限年龄衔接", () {
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.Zi,
        birthSect: BirthSect.day,
        rulerPalaces: {
          ZhuLuoRuler.saturn: EnumTwelveGong.Si,
          ZhuLuoRuler.mercury: EnumTwelveGong.Zi,
          ZhuLuoRuler.jupiter: EnumTwelveGong.Mao,
        },
        maxAge: 60,
        config: classicForwardUntilTargetConfig,
      );
      final results = calculateZhuLuoSanXian(input);
      
      // 找到交限年（初限→中限）
      final transition = results.firstWhere((r) => r.isTransitionYear);
      
      // 中限从交限当年开始
      final middleStart = results.firstWhere((r) => r.age == transition.age);
      expect(middleStart.stage, LimitStage.middle);
      
      // 中限从自身起宫重起（不承接初限末宫）
      expect(middleStart.palace, EnumTwelveGong.Zi);
    });
  });

  group("SpiralSeriesSpec mapping", () {
    test("mapToSpiralSeriesSpec produces correct structure", () {
      final results = [
        ZhuLuoYearResult(
          age: 1, stage: LimitStage.first, ruler: ZhuLuoRuler.saturn,
          palace: EnumTwelveGong.Si, algorithmId: ZhuLuoAlgorithmId.classicForwardUntilTarget,
          phase: "hold", isTransitionYear: false, usedBridge: false,
        ),
        ZhuLuoYearResult(
          age: 6, stage: LimitStage.first, ruler: ZhuLuoRuler.saturn,
          palace: EnumTwelveGong.Wu, algorithmId: ZhuLuoAlgorithmId.classicForwardUntilTarget,
          phase: "direct", isTransitionYear: false, usedBridge: false,
        ),
      ];
      
      final spec = mapToSpiralSeriesSpec(
        results: results,
        limitId: 'limit-0',
        innerRadius: 100,
        outerRadius: 200,
      );
      
      expect(spec.id, 'limit-0');
      expect(spec.segments.length, 2);
      expect(spec.segments[0].styleKey, kStyleKeyBenGong);
      expect(spec.segments[1].styleKey, kStyleKeyLingNian);
    });
  });
}
