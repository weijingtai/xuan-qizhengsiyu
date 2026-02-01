import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:path/path.dart' as path;
import 'package:common/enums/enum_stars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/utils/coordinate_converter.dart';
import 'package:qizhengsiyu/utils/star_enter_info_calculator.dart';

void main() {
  final baseGong = [
    GongDegree(gong: EnumTwelveGong.fromStrZhi("子"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("亥"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("戌"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("酉"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("申"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("未"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("午"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("巳"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("辰"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("卯"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("寅"), degree: 30),
    GongDegree(gong: EnumTwelveGong.fromStrZhi("丑"), degree: 30),
  ];
  final baseconstellations = [
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("危"), degree: 20),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("室"), degree: 16),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("壁"), degree: 13),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("奎"), degree: 11),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("娄"), degree: 13),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("胃"), degree: 12),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("昴"), degree: 9),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("毕"), degree: 15),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("觜"), degree: 1),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("参"), degree: 11),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("井"), degree: 31),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("鬼"), degree: 5),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("柳"), degree: 17),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("星"), degree: 8),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("张"), degree: 18),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("翼"), degree: 17),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("轸"), degree: 13),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("角"), degree: 11),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("亢"), degree: 11),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("氐"), degree: 18),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("房"), degree: 5),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("心"), degree: 8),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("尾"), degree: 15),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("箕"), degree: 9),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("斗"), degree: 24),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("牛"), degree: 8),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("女"), degree: 11),
    ConstellationDegree(
        constellation: Enum28Constellations.fromStarName("虚"), degree: 10)
  ];

  group("宫位计算测试", () {
    final newZiGongZeroSequence = StarEnterInfoCalculator.generateGongSequence(
      GongDegree(gong: EnumTwelveGong.fromStrZhi("子"), degree: 0),
      baseGong,
    );
    final newZiGong15Sequence = StarEnterInfoCalculator.generateGongSequence(
      GongDegree(gong: EnumTwelveGong.fromStrZhi("子"), degree: 15),
      baseGong,
    );

    final newXuGong0Sequence = StarEnterInfoCalculator.generateGongSequence(
      GongDegree(gong: EnumTwelveGong.fromStrZhi("戌"), degree: 0),
      baseGong,
    );
    test('测试宫位查找 res1', () {
      final res = StarEnterInfoCalculator.doFindGong(
        15,
        newZiGongZeroSequence,
      );
      expect(res.gong, EnumTwelveGong.fromStrZhi("子"));
      expect(res.degree, 15);
    });
    test('测试宫位查找 res2', () {
      newZiGong15Sequence.forEach((e) => print(e.toJson()));
      final res2 = StarEnterInfoCalculator.doFindGong(
        15,
        newZiGong15Sequence,
      );
      expect(res2.gong, EnumTwelveGong.fromStrZhi("子"));
      expect(res2.degree, 30, reason: "子宫15度");
    });
    test('测试宫位查找 res3', () {
      final res3 = StarEnterInfoCalculator.doFindGong(
        0,
        newZiGong15Sequence,
      );
      expect(res3.gong, EnumTwelveGong.fromStrZhi("子"));
      expect(res3.degree, 15);
    });
    test('测试宫位查找 res3_1', () {
      final res3_1 = StarEnterInfoCalculator.doFindGong(
        355,
        newZiGong15Sequence,
      );
      expect(res3_1.gong, EnumTwelveGong.fromStrZhi("子"));
      expect(res3_1.degree, 10);
    });
    test('测试宫位查找 res4', () {
      final res4 = StarEnterInfoCalculator.doFindGong(
        0,
        newXuGong0Sequence,
      );
      expect(res4.gong, EnumTwelveGong.fromStrZhi("戌"));
      expect(res4.degree, 0);
    });
    test('测试宫位查找 res5', () {
      final res5 = StarEnterInfoCalculator.doFindGong(
        15,
        newXuGong0Sequence,
      );
      expect(res5.gong, EnumTwelveGong.fromStrZhi("戌"));
      expect(res5.degree, 15);
    });
  });

  group('星座计算测试', () {
    test('测试星座查找', () {
      final newSequence = StarEnterInfoCalculator.generateConstellationSequence(
        ConstellationDegree(
            constellation: Enum28Constellations.fromStarName("室"), degree: 3),
        baseconstellations,
      );
      // expect(res.name, "壁");
      // expect(res.atDegree, 12);

      final res2 =
          StarEnterInfoCalculator.doFindConstellation(356, newSequence);
      expect(res2.constellation.starName, "危");
      expect(res2.degree, 19);

      final res3 =
          StarEnterInfoCalculator.doFindConstellation(359, newSequence);
      expect(res3.constellation.starName, "室");
      expect(res3.degree, 2);

      final res4 = StarEnterInfoCalculator.doFindConstellation(2, newSequence);
      expect(res4.constellation.starName, "室");
      expect(res4.degree, 5);

      final res5 =
          StarEnterInfoCalculator.doFindConstellation(360, newSequence);
      expect(res5.constellation.starName, "室");
      expect(res5.degree, 3);
    });

    // 方法1：使用 Directory.current
    final currentDir = Directory.current;
    print('当前工作目录：${currentDir.path}');

    // 方法2：使用 Platform.script 获取当前脚本路径，然后向上查找项目根目录
    final scriptPath = Platform.script.toFilePath();
    print('当前脚本路径：$scriptPath');

    // 方法3：使用 path 包处理路径
    final projectRoot = path.normalize(path.join(currentDir.path, '..'));
    print('项目根目录：$projectRoot');
    test('测试星体入宫信息 - 古宿', () {
      // load from jsonfile

      final jsonFile = File(
          '$projectRoot/assets/qizhengsiyu/ecliptic_tropical_classical.json');
      final jsonString = jsonFile.readAsStringSync();

      ZhouTianModel zhouTianModel =
          ZhouTianModel.fromJson(jsonDecode(jsonString));
      // 孛星角度：98°36'33"
      final beiAngle = CoordinateConverter.dmsToDd(98, 36, 33);
      StarEnterInfoCalculator starEnterInfoCalculator = StarEnterInfoCalculator(
        zhouTianModel: zhouTianModel,
      );

      // print('孛星入宫信息（古宿）：${beiEnterInfo.toJson()}');

      // 土星角度：348°28'45"
      final saturnAngle = CoordinateConverter.dmsToDd(348, 28, 45);

      final starDegreeSeq = [
        StarDegree(
            star: EnumStars.Bei,
            degree: StarEnterInfoCalculator.toDecimal(beiAngle, 3)),
        StarDegree(
            star: EnumStars.Saturn,
            degree: StarEnterInfoCalculator.toDecimal(saturnAngle, 3))
      ];
      final res = starEnterInfoCalculator.calculate(starDegreeSeq);
      final saturn = res.firstWhere((e) => e.star == EnumStars.Saturn);
      final bei = res.firstWhere((e) => e.star == EnumStars.Bei);
      // print('土星入宫信息（古宿）：${jsonEncode(saturn.toJson())}');
      // print('孛星入宫信息（古宿）：${jsonEncode(bei.toJson())}');
      expect(saturn.atDegree, 348.479);
      expect(bei.atDegree, 98.609);

      expect(saturn.gong, EnumTwelveGong.fromStrZhi("亥"));
      expect(saturn.atGongDegree, 18.479);
      expect(saturn.inn, Enum28Constellations.fromStarName("室"));
      expect(saturn.atInnDegree, 14.879);

      expect(bei.gong, EnumTwelveGong.fromStrZhi("未"));
      expect(bei.atGongDegree, 8.609);
      expect(bei.inn, Enum28Constellations.fromStarName("井"));
      expect(bei.atInnDegree, 16.809);
    });

    test('测试星体入宫信息 - 古宿矫正', () {
      final jsonFile = File(
          '$projectRoot/assets/qizhengsiyu/ecliptic_tropical_classical_adjusted.json');
      final jsonString = jsonFile.readAsStringSync();

      ZhouTianModel zhouTianModel =
          ZhouTianModel.fromJson(jsonDecode(jsonString));
      // 孛星角度：98°36'33"
      final beiAngle = CoordinateConverter.dmsToDd(98, 36, 33);
      StarEnterInfoCalculator starEnterInfoCalculator = StarEnterInfoCalculator(
        zhouTianModel: zhouTianModel,
      );

      // print('孛星入宫信息（古宿）：${beiEnterInfo.toJson()}');

      // 土星角度：348°28'45"
      final saturnAngle = CoordinateConverter.dmsToDd(348, 28, 45);

      final starDegreeSeq = [
        StarDegree(
            star: EnumStars.Bei,
            degree: StarEnterInfoCalculator.toDecimal(beiAngle, 3)),
        StarDegree(
            star: EnumStars.Saturn,
            degree: StarEnterInfoCalculator.toDecimal(saturnAngle, 3))
      ];
      final res = starEnterInfoCalculator.calculate(starDegreeSeq);
      final saturn = res.firstWhere((e) => e.star == EnumStars.Saturn);
      final bei = res.firstWhere((e) => e.star == EnumStars.Bei);
      // print('土星入宫信息（古宿）：${jsonEncode(saturn.toJson())}');
      // print('孛星入宫信息（古宿）：${jsonEncode(bei.toJson())}');
      expect(saturn.atDegree, 348.479);
      expect(bei.atDegree, 98.609);

      expect(saturn.gong, EnumTwelveGong.fromStrZhi("亥"));
      expect(saturn.atGongDegree, 18.479);
      expect(saturn.inn, Enum28Constellations.fromStarName("室"));
      expect(saturn.atInnDegree, 1.179);

      expect(bei.gong, EnumTwelveGong.fromStrZhi("未"));
      expect(bei.atGongDegree, 8.609);
      expect(bei.inn, Enum28Constellations.fromStarName("井"));
      expect(bei.atInnDegree, 3.109);
    });

    test('测试星体入宫信息 - 今宿', () {
      final jsonFile =
          File('$projectRoot/assets/qizhengsiyu/ecliptic_tropical_morden.json');
      final jsonString = jsonFile.readAsStringSync();

      ZhouTianModel zhouTianModel =
          ZhouTianModel.fromJson(jsonDecode(jsonString));
      // 孛星角度：98°36'33"
      final beiAngle = CoordinateConverter.dmsToDd(98, 36, 33);
      StarEnterInfoCalculator starEnterInfoCalculator = StarEnterInfoCalculator(
        zhouTianModel: zhouTianModel,
      );

      // print('孛星入宫信息（古宿）：${beiEnterInfo.toJson()}');

      // 土星角度：348°28'45"
      final saturnAngle = CoordinateConverter.dmsToDd(348, 28, 45);

      final starDegreeSeq = [
        StarDegree(
            star: EnumStars.Bei,
            degree: StarEnterInfoCalculator.toDecimal(beiAngle, 3)),
        StarDegree(
            star: EnumStars.Saturn,
            degree: StarEnterInfoCalculator.toDecimal(saturnAngle, 3))
      ];
      final res = starEnterInfoCalculator.calculate(starDegreeSeq);
      final saturn = res.firstWhere((e) => e.star == EnumStars.Saturn);
      final bei = res.firstWhere((e) => e.star == EnumStars.Bei);
      // print('土星入宫信息（古宿）：${jsonEncode(saturn.toJson())}');
      // print('孛星入宫信息（古宿）：${jsonEncode(bei.toJson())}');
      expect(saturn.atDegree, 348.479);
      expect(bei.atDegree, 98.609);

      expect(saturn.gong, EnumTwelveGong.fromStrZhi("亥"));
      expect(saturn.atGongDegree, 18.479);
      expect(saturn.inn, Enum28Constellations.fromStarName("危"));
      expect(saturn.atInnDegree, 15.099);

      expect(bei.gong, EnumTwelveGong.fromStrZhi("未"));
      expect(bei.atGongDegree, 8.609);
      expect(bei.inn, Enum28Constellations.fromStarName("井"));
      expect(bei.atInnDegree, 3.349);
    });
  });
}
