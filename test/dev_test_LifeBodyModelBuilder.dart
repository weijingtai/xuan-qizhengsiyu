import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/services/life_body_model_builder.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';

void main() {
  group("确定命宫", () {
    test('午时生人，辰时立命', () {
      EnumTwelveGong atGong = LifeBodyModelBuilder.calculateLife(
          DiZhi.WU, EnumTwelveGong.Yin, DiZhi.CHEN);
      expect(atGong, equals(EnumTwelveGong.Zi));
    });
    test('午时生人，卯时立命', () {
      EnumTwelveGong atGong = LifeBodyModelBuilder.calculateLife(
          DiZhi.WU, EnumTwelveGong.Yin, DiZhi.MAO);
      expect(atGong, equals(EnumTwelveGong.Hai));
    });
  });
  group("确定命度", () {
    test('午时生人，子宫立命 太阳入宫22度', () {
      LifeBodyModelBuilder.settleLifeStarInn(
          PanelCelesticalInfo.eclipticTropicalModern,
          EnumTwelveGong.Zi,
          22.712);
      // expect(atGong, equals(EnumTwelveGong.Zi));
    });
    test('午时生人，子宫立命 太阳入宫1度', () {
      LifeBodyModelBuilder.settleLifeStarInn(
          PanelCelesticalInfo.eclipticTropicalModern, EnumTwelveGong.Zi, 1);
      // expect(atGong, equals(EnumTwelveGong.Zi));
    });
    test('午时生人，子宫立命 太阳入宫29度', () {
      LifeBodyModelBuilder.settleLifeStarInn(
          PanelCelesticalInfo.eclipticTropicalModern, EnumTwelveGong.Zi, 29);
      // expect(atGong, equals(EnumTwelveGong.Zi));
    });
  });
}
