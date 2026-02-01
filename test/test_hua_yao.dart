import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  // final currentDir = Directory.current;
  // print('当前工作目录：${currentDir.path}');

  // 方法2：使用 Platform.script 获取当前脚本路径，然后向上查找项目根目录
  // final scriptPath = Platform.script.toFilePath();
  // print('当前脚本路径：$scriptPath');

  // 方法3：使用 path 包处理路径
  final projectRoot = path.normalize(path.join(Directory.current.path, '..'));

  // 天干化曜
  final tianGanHuaYaoJsonFile =
      File('$projectRoot/assets/shen_sha/74_huayao_tiangan.json');
  final tianGanHuaYaoJsonString = tianGanHuaYaoJsonFile.readAsStringSync();
  final tianGanList = json.decode(tianGanHuaYaoJsonString) as List;
  List<TianGanHuaYao> tianGanHuaYao =
      tianGanList.map((e) => TianGanHuaYao.fromJson(e)).toList();
  // 地支化曜
  final diZhiHuaYaoJsonFile =
      File('$projectRoot/assets/shen_sha/74_huayao_dizhi.json');
  final diZhiHuaYaoJsonString = diZhiHuaYaoJsonFile.readAsStringSync();
  final diZhiList = json.decode(diZhiHuaYaoJsonString) as List;
  List<DiZhiHuaYao> diZhiHuaYao =
      diZhiList.map((e) => DiZhiHuaYao.fromJson(e)).toList();

  // 其他化曜
  final othersHuaYaoJsonFile =
      File('$projectRoot/assets/shen_sha/74_huayao_others.json');
  final othersHuaYaoJsonString = othersHuaYaoJsonFile.readAsStringSync();
  final othersHuaYaoList = json.decode(othersHuaYaoJsonString) as List;
  othersHuaYaoList.forEach((element) {
    print(element);
  });
  List<OthersHuaYao> othersHuaYao =
      othersHuaYaoList.map((e) => OthersHuaYao.fromJson(e)).toList();

  group("卦气系", () {
    test("化曜 职元 乙亥年 子宫命", () {
      final result = HuaYaoManager.generateZhiYuanAndJuZhu(
          JiaZi.YI_HAI, EnumTwelveGong.Zi);
      expect(result[0], equals(EnumStars.Moon), reason: result[0].name);
      expect(result[1], equals(EnumStars.Mars), reason: result[1].name);

      final result2 =
          HuaYaoManager.generateDiYuanLu(JiaZi.YI_HAI, EnumTwelveGong.Zi);
      expect(result2, equals(EnumStars.Mercury), reason: result2.name);
    });
    test("化曜 职元 丙戌 寅宫命", () {
      final result = HuaYaoManager.generateZhiYuanAndJuZhu(
          JiaZi.BING_XU, EnumTwelveGong.Yin);
      expect(result[0], equals(EnumStars.Jupiter), reason: result[0].name);
      expect(result[1], equals(EnumStars.Qi), reason: result[1].name);

      final result2 =
          HuaYaoManager.generateDiYuanLu(JiaZi.BING_XU, EnumTwelveGong.Yin);
      expect(result2, equals(EnumStars.Mars), reason: result2.name);
    });

    test("化曜 职元、局主 甲辰 寅宫命", () {
      final result = HuaYaoManager.generateZhiYuanAndJuZhu(
          JiaZi.JIA_CHEN, EnumTwelveGong.Yin);
      expect(result[0], equals(EnumStars.Venus), reason: result[0].name);
      expect(result[1], equals(EnumStars.Ji), reason: result[1].name);

      final result2 =
          HuaYaoManager.generateDiYuanLu(JiaZi.JIA_CHEN, EnumTwelveGong.Yin);
      expect(result2, equals(EnumStars.Mercury), reason: result2.name);
    });
  });

  group("三元禄", () {
    test("人元禄 甲申年 命宫寅 官禄巳", () {
      EnumStars stars =
          HuaYaoManager.generateRenYuanLu(JiaZi.JIA_SHEN, EnumTwelveGong.Si);
      expect(stars, equals(EnumStars.Jupiter), reason: stars.name);
    });

    test("人元禄 甲辰年 命宫酉 官禄子", () {
      EnumStars stars =
          HuaYaoManager.generateRenYuanLu(JiaZi.JIA_CHEN, EnumTwelveGong.Zi);
      expect(stars, equals(EnumStars.Mercury), reason: stars.name);
    });

    test("人元禄 丙午年 命宫酉 官禄子", () {
      EnumStars stars =
          HuaYaoManager.generateRenYuanLu(JiaZi.BING_WU, EnumTwelveGong.Zi);
      expect(stars, equals(EnumStars.Mars), reason: stars.name);
    });

    test("天元禄 甲辰年 命宫酉", () {
      EnumStars stars =
          HuaYaoManager.generateTianYuanLu(JiaZi.JIA_CHEN, EnumTwelveGong.You);
      expect(stars, equals(EnumStars.Luo), reason: stars.name);
    });

    test("天元禄 甲辰年 命宫亥", () {
      EnumStars stars =
          HuaYaoManager.generateTianYuanLu(JiaZi.JIA_CHEN, EnumTwelveGong.Hai);
      expect(stars, equals(EnumStars.Bei), reason: stars.name);
    });

    test("天元禄 丙午年 命宫酉", () {
      EnumStars stars =
          HuaYaoManager.generateTianYuanLu(JiaZi.BING_WU, EnumTwelveGong.Hai);
      expect(stars, equals(EnumStars.Moon), reason: stars.name);
    });

    test("天经、地纬 丙午年 命宫酉", () {
      final result = HuaYaoManager.generateTianJingAndDiWei(
          JiaZi.BING_WU, EnumTwelveGong.You);
      expect(result.item1, equals(EnumStars.Mars), reason: result.item1.name);
      expect(result.item2, equals(EnumStars.Venus), reason: result.item2.name);
    });

    test("天经、地纬 甲辰年 命酉", () {
      final result = HuaYaoManager.generateTianJingAndDiWei(
          JiaZi.JIA_CHEN, EnumTwelveGong.You);
      expect(result.item1, equals(EnumStars.Mercury),
          reason: result.item1.name);
      expect(result.item2, equals(EnumStars.Venus), reason: result.item2.name);
    });
    test("天经、地纬 甲辰年 命子", () {
      final result = HuaYaoManager.generateTianJingAndDiWei(
          JiaZi.JIA_CHEN, EnumTwelveGong.Zi);
      expect(result.item1, equals(EnumStars.Mars), reason: result.item1.name);
      expect(result.item2, equals(EnumStars.Mercury),
          reason: result.item2.name);
    });
  });

  group("科甲", () {
    test("科甲 命子", () {
      EnumStars stars = HuaYaoManager.getKeJia(EnumTwelveGong.Zi);
      expect(stars, equals(EnumStars.Sun), reason: stars.name);
    });
    test("科甲 命寅", () {
      EnumStars stars = HuaYaoManager.getKeJia(EnumTwelveGong.Yin);
      expect(stars, equals(EnumStars.Mercury), reason: stars.name);
    });
  });

  group("化曜 all", () {
    final fakeRepository = FakeHuaYaoRepository(
      tianGanHuaYao: tianGanHuaYao,
      diZhiHuaYao: diZhiHuaYao,
      othersHuaYao: othersHuaYao,
    );
    final huaYaoService = HuaYaoService(repository: fakeRepository);
    final huaYaoManger = HuaYaoManager(huaYaoService: huaYaoService);
    test("化曜总数 41 (多一个天官，即八字中的正官)", () async {
      final result = await huaYaoManger.calculate(
          mingGong: EnumTwelveGong.Zi,
          yearJiaZi: JiaZi.JIA_CHEN,
          monthJiaZi: JiaZi.WU_CHEN);
      expect(result.length, equals(41),
          reason: result.keys.map((k) => k.name).toList().toString());
    });
  });
}

class FakeHuaYaoRepository implements HuaYaoRepository {
  final List<TianGanHuaYao> tianGanHuaYao;
  final List<DiZhiHuaYao> diZhiHuaYao;
  final List<OthersHuaYao> othersHuaYao;

  FakeHuaYaoRepository({
    required this.tianGanHuaYao,
    required this.diZhiHuaYao,
    required this.othersHuaYao,
  });

  @override
  Future<List<TianGanHuaYao>> getTianGanHuaYao() async {
    return tianGanHuaYao;
  }

  @override
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async {
    return diZhiHuaYao;
  }

  @override
  Future<List<OthersHuaYao>> getOthersHuaYao() async {
    return othersHuaYao;
  }
}
