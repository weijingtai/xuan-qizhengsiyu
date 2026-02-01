import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:qizhengsiyu/utils/star_degree_inn_gong_helper.dart';
import 'package:tuple/tuple.dart';

void main() {
  double testSunangle = 211.02;
  group("星体入宫", () {
    test("入戌宫 1°", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 1,
          rangeAngleEachSide: 4);
      Tuple2<EnumTwelveGong, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(
              uiStarModel.angle);
      expect(result,
          equals(const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 1)));
    });

    test("入戌宫 29.5", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 29.5,
          rangeAngleEachSide: 4);
      Tuple2<EnumTwelveGong, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(
              uiStarModel.angle);
      expect(
          result,
          equals(
              const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 29.5)));
    });
    test("入酉宫 29.5", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 31.5,
          rangeAngleEachSide: 4);
      Tuple2<EnumTwelveGong, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(
              uiStarModel.angle);
      expect(
          result,
          equals(
              const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 1.5)));
    });

    test("入酉宫 0", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 30,
          rangeAngleEachSide: 4);
      Tuple2<EnumTwelveGong, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(
              uiStarModel.angle);
      expect(result,
          equals(const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 0)));
    });
    test("入申宫 0", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 60,
          rangeAngleEachSide: 4);
      Tuple2<EnumTwelveGong, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterDiZhiGong(
              uiStarModel.angle);
      expect(result,
          equals(const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 0)));
    });
  });

  group("星体入宿度", () {
    test("入室火 6.5", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 0,
          rangeAngleEachSide: 4);
      Tuple2<Enum28Constellations, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterStarInn(
              uiStarModel.angle,
              StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
              QiZhengSiYuConstantResources
                  .ZodiacTropicalModernStarsInnSystemMapper);
      expect(
          result,
          equals(Tuple2<Enum28Constellations, double>(
              Enum28Constellations.Shi_Huo_Zhu,
              StarPanelType.ZodiacTropicalModernStarsInnSystemMapper
                  .firstAtZeroDegree)));
    });
    test("入壁水 1", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 11.25,
          rangeAngleEachSide: 4);
      Tuple2<Enum28Constellations, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterStarInn(
              uiStarModel.angle,
              StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
              QiZhengSiYuConstantResources
                  .ZodiacTropicalModernStarsInnSystemMapper);
      expect(
          result,
          equals(const Tuple2<Enum28Constellations, double>(
              Enum28Constellations.Bi_Shui_Yu, 1)));
    });

    test("入室火 1", () {
      UIStarModel uiStarModel = UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 360 - 6.5 + 1,
          rangeAngleEachSide: 4);
      Tuple2<Enum28Constellations, double> result =
          StarDegreeInnGongHelper.calculateStarAngleEnterStarInn(
              uiStarModel.angle,
              StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
              QiZhengSiYuConstantResources
                  .ZodiacTropicalModernStarsInnSystemMapper);
      expect(
          result,
          equals(const Tuple2<Enum28Constellations, double>(
              Enum28Constellations.Shi_Huo_Zhu, 1.0)));
    });
  });
}
