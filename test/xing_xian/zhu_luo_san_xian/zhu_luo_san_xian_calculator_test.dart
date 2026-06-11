import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_palace_math.dart';

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
  group("A law", () {
    test("Saturn in Si", () {
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.Zi,
        birthSect: BirthSect.day,
        rulerPalaces: {ZhuLuoRuler.saturn: EnumTwelveGong.Si},
        maxAge: 30,
        config: classicInverseSectionsConfig,
      );
      final results = calculateZhuLuoSanXian(input);
      expect(results.firstWhere((r) => r.age == 5).palace, EnumTwelveGong.Si);
      expect(results.firstWhere((r) => r.age == 15).palace, EnumTwelveGong.Mao);
      expect(results.firstWhere((r) => r.age == 25).palace, EnumTwelveGong.Chou);
      expect(results.firstWhere((r) => r.age == 26).palace, EnumTwelveGong.Yin);
    });
  });

  group("B law", () {
    test("Venus in Yin", () {
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
        maxAge: 10,
        config: directAnnualWithBridgeConfig,
      );
      final results = calculateZhuLuoSanXian(input);
      expect(results.firstWhere((r) => r.age == 4).palace, EnumTwelveGong.Yin);
      expect(results.firstWhere((r) => r.age == 5).palace, EnumTwelveGong.Mao);
      expect(results.firstWhere((r) => r.age == 7).palace, EnumTwelveGong.Si);
    });
  });

  group("A vs B differ", () {
    test("age 19 differs", () {
      final a = calculateZhuLuoSanXian(ZhuLuoInput(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
        maxAge: 20,
        config: classicInverseSectionsConfig,
      ));
      final b = calculateZhuLuoSanXian(ZhuLuoInput(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
        maxAge: 20,
        config: directAnnualWithBridgeConfig,
      ));
      expect(a.firstWhere((r) => r.age == 19).palace, isNot(b.firstWhere((r) => r.age == 19).palace));
    });
  });

  group("Frederick B law", () {
    test("key ages", () {
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        rulerPalaces: {
          ZhuLuoRuler.venus: EnumTwelveGong.Yin,
          ZhuLuoRuler.moon: EnumTwelveGong.Wu,
          ZhuLuoRuler.mars: EnumTwelveGong.Zi,
        },
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      final results = calculateZhuLuoSanXian(input);
      expect(results.firstWhere((r) => r.age == 19).palace, EnumTwelveGong.Si);
      expect(results.firstWhere((r) => r.age == 29).palace, EnumTwelveGong.Mao);
      expect(results.firstWhere((r) => r.age == 32).palace, EnumTwelveGong.Wu);
      expect(results.firstWhere((r) => r.age == 46).palace, EnumTwelveGong.Shen);
      expect(results.firstWhere((r) => r.age == 47).palace, EnumTwelveGong.Shen);
      expect(results.firstWhere((r) => r.age == 54).palace, EnumTwelveGong.Zi);
      expect(results.firstWhere((r) => r.age == 55).palace, EnumTwelveGong.Zi);
      expect(results.firstWhere((r) => r.age == 61).palace, EnumTwelveGong.Wu);
      expect(results.firstWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);
      expect(results.where((r) => r.age == 54).length, 1);
      expect(results.where((r) => r.age == 55).length, 1);
    });

    test("bridge year metadata", () {
      final input = ZhuLuoInput(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        rulerPalaces: {
          ZhuLuoRuler.venus: EnumTwelveGong.Yin,
          ZhuLuoRuler.moon: EnumTwelveGong.Wu,
          ZhuLuoRuler.mars: EnumTwelveGong.Zi,
        },
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      final results = calculateZhuLuoSanXian(input);
      expect(results.firstWhere((r) => r.age == 54).usedBridge, true);
      expect(results.firstWhere((r) => r.age == 55).isTransitionYear, true);
    });
  });
}
