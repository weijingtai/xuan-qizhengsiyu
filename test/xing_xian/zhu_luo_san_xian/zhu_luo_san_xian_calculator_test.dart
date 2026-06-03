import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';

void main() {
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
        lifePalace: EnumTwelveGong.Yin,
        birthSect: BirthSect.day,
        rulerPalaces: {ZhuLuoRuler.mars: EnumTwelveGong.Yin},
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
        lifePalace: EnumTwelveGong.Yin,
        birthSect: BirthSect.day,
        rulerPalaces: {ZhuLuoRuler.venus: EnumTwelveGong.Yin},
        maxAge: 20,
        config: classicInverseSectionsConfig,
      ));
      final b = calculateZhuLuoSanXian(ZhuLuoInput(
        lifePalace: EnumTwelveGong.Yin,
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
        lifePalace: EnumTwelveGong.Si,
        birthSect: BirthSect.night,
        rulerPalaces: {
          ZhuLuoRuler.moon: EnumTwelveGong.Si,
          ZhuLuoRuler.venus: EnumTwelveGong.You,
          ZhuLuoRuler.mars: EnumTwelveGong.Xu,
        },
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );
      final results = calculateZhuLuoSanXian(input);
      expect(results.firstWhere((r) => r.age == 19).palace, EnumTwelveGong.Si);
      expect(results.firstWhere((r) => r.age == 29).palace, EnumTwelveGong.Mao);
      expect(results.firstWhere((r) => r.age == 54).palace, EnumTwelveGong.Zi);
      expect(results.firstWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);
      expect(results.where((r) => r.age == 54).length, 1);
      expect(results.where((r) => r.age == 55).length, 1);
    });
  });
}
