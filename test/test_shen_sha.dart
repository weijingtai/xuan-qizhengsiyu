// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:io';
import 'package:common/enums/enum_jia_zi.dart';

import 'package:common/models/shen_sha.dart';
import 'package:common/models/shen_sha_bundled.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/utils/collections_utils.dart';
import 'package:path/path.dart' as path;

import 'package:common/enums/enum_di_zhi.dart';

import 'package:common/models/shen_sha_tian_gan.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';

import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  group("太岁驾前轮宫煞", () {
    test("子年", () {
      final Map<EnumTwelveGong, List<EnumBeforeTaiSuiShenSha>> resultMapper =
          EnumBeforeTaiSuiShenSha.getByTiaSui(EnumTwelveGong.Zi);
      expect(resultMapper.length, equals(12));
      expect(resultMapper[EnumTwelveGong.Zi]!.any((t) => t.order != 0),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Chou]!.any((t) => t.order != 1),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Hai]!.any((t) => t.order != 11),
          equals(false));
    });
    test("亥年", () {
      final Map<EnumTwelveGong, List<EnumBeforeTaiSuiShenSha>> resultMapper =
          EnumBeforeTaiSuiShenSha.getByTiaSui(EnumTwelveGong.Hai);
      expect(resultMapper.length, equals(12));
      // print(resultMapper[EnumTwelveGong.Zi]!.first.order);
      expect(resultMapper[EnumTwelveGong.Zi]!.any((t) => t.order != 1),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Chou]!.any((t) => t.order != 2),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Hai]!.any((t) => t.order != 0),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Xu]!.any((t) => t.order != 11),
          equals(false));
    });
    test("丑年", () {
      final Map<EnumTwelveGong, List<EnumBeforeTaiSuiShenSha>> resultMapper =
          EnumBeforeTaiSuiShenSha.getByTiaSui(EnumTwelveGong.Chou);
      expect(resultMapper.length, equals(12));
      // print(resultMapper[EnumTwelveGong.Zi]!.first.order);
      expect(resultMapper[EnumTwelveGong.Zi]!.any((t) => t.order != 11),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Chou]!.any((t) => t.order != 0),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Hai]!.any((t) => t.order != 10),
          equals(false));
      expect(resultMapper[EnumTwelveGong.Xu]!.any((t) => t.order != 9),
          equals(false));
    });
  });
  group("马前诸煞", () {
    test("子年", () {
      final Map<EnumTwelveGong, EnumShenShaBeforeHouseStar> resultMapper =
          EnumShenShaBeforeHouseStar.getByHousePosition(EnumTwelveGong.Zi);
      expect(resultMapper.length, equals(12));
    });
  });
  group("太岁驾后轮宫煞", () {
    test("子年", () {
      final Map<EnumTwelveGong, List<EnumAfterTaiSuiShenSha>> resultMapper =
          EnumAfterTaiSuiShenSha.getByTiaSui(EnumTwelveGong.Zi);
      expect(resultMapper.length, equals(5));

      expect(resultMapper[EnumTwelveGong.Mao]!.first,
          EnumAfterTaiSuiShenSha.HongLuan,
          reason: resultMapper[EnumTwelveGong.Mao]!.first.toString());
      expect(resultMapper[EnumTwelveGong.Chen]!.first,
          EnumAfterTaiSuiShenSha.PiTou,
          reason: resultMapper[EnumTwelveGong.Chen]!.first.toString());
      expect(
          resultMapper[EnumTwelveGong.Wu]!.first, EnumAfterTaiSuiShenSha.TianKu,
          reason: resultMapper[EnumTwelveGong.Wu]!.first.toString());
      expect(resultMapper[EnumTwelveGong.You]!.first,
          EnumAfterTaiSuiShenSha.TianXi,
          reason: resultMapper[EnumTwelveGong.You]!.first.toString());
      expect(resultMapper[EnumTwelveGong.Xu]!.length, equals(3),
          reason: resultMapper[EnumTwelveGong.Xu]!.length.toString());
    });

    test("亥年", () {
      final Map<EnumTwelveGong, List<EnumAfterTaiSuiShenSha>> resultMapper =
          EnumAfterTaiSuiShenSha.getByTiaSui(EnumTwelveGong.Hai);
      expect(resultMapper.length, equals(5));

      expect(resultMapper[EnumTwelveGong.Chen]!.first,
          EnumAfterTaiSuiShenSha.HongLuan,
          reason: resultMapper[EnumTwelveGong.Chen]!.first.toString());
      expect(
          resultMapper[EnumTwelveGong.Si]!.first, EnumAfterTaiSuiShenSha.PiTou,
          reason: resultMapper[EnumTwelveGong.Si]!.first.toString());
      expect(resultMapper[EnumTwelveGong.Wei]!.first,
          EnumAfterTaiSuiShenSha.TianKu,
          reason: resultMapper[EnumTwelveGong.Wei]!.first.toString());

      expect(
          resultMapper[EnumTwelveGong.Xu]!.first, EnumAfterTaiSuiShenSha.TianXi,
          reason: resultMapper[EnumTwelveGong.Xu]!.first.toString());
      expect(resultMapper[EnumTwelveGong.Hai]!.length, equals(3),
          reason: resultMapper[EnumTwelveGong.Hai]!.length.toString());
    });

    test("丑年", () {
      final Map<EnumTwelveGong, List<EnumAfterTaiSuiShenSha>> resultMapper =
          EnumAfterTaiSuiShenSha.getByTiaSui(EnumTwelveGong.Chou);
      expect(resultMapper.length, equals(5));

      expect(resultMapper[EnumTwelveGong.Yin]!.first,
          EnumAfterTaiSuiShenSha.HongLuan,
          reason: resultMapper[EnumTwelveGong.Yin]!.first.toString());
      expect(
          resultMapper[EnumTwelveGong.Mao]!.first, EnumAfterTaiSuiShenSha.PiTou,
          reason: resultMapper[EnumTwelveGong.Mao]!.first.toString());
      expect(
          resultMapper[EnumTwelveGong.Si]!.first, EnumAfterTaiSuiShenSha.TianKu,
          reason: resultMapper[EnumTwelveGong.Si]!.first.toString());

      expect(resultMapper[EnumTwelveGong.Shen]!.first,
          EnumAfterTaiSuiShenSha.TianXi,
          reason: resultMapper[EnumTwelveGong.Shen]!.first.toString());
      expect(resultMapper[EnumTwelveGong.You]!.length, equals(3),
          reason: resultMapper[EnumTwelveGong.You]!.length.toString());
    });
  });
  group("马前诸煞", () {
    test("亥", () {
      final Map<EnumTwelveGong, EnumShenShaBeforeHouseStar> resultMapper =
          EnumShenShaBeforeHouseStar.getByHousePosition(EnumTwelveGong.Hai);
      expect(resultMapper.length, equals(12));
      expect(
          resultMapper[EnumTwelveGong.Hai]!, EnumShenShaBeforeHouseStar.YiMa);
      expect(resultMapper[EnumTwelveGong.Zi]!, EnumShenShaBeforeHouseStar.LiuE);
      expect(resultMapper[EnumTwelveGong.Chou]!,
          EnumShenShaBeforeHouseStar.HuaGai);
    });
  });

  final currentDir = Directory.current;
  print('当前工作目录：${currentDir.path}');

  // 方法2：使用 Platform.script 获取当前脚本路径，然后向上查找项目根目录
  final scriptPath = Platform.script.toFilePath();
  print('当前脚本路径：$scriptPath');

  // 方法3：使用 path 包处理路径
  final projectRoot = path.normalize(path.join(currentDir.path, '..'));
  print('项目根目录：$projectRoot');

  final tianGanJsonFile =
      File('$projectRoot/assets/shen_sha/74_shensha_tiangan.json');
  final tianGanJsonString = tianGanJsonFile.readAsStringSync();
  final tianGanList = json.decode(tianGanJsonString) as List;
  List<TianGanShenSha> tianGanShenSha =
      tianGanList.map((e) => TianGanShenSha.fromJson(e)).toList();

  final yearDiZhiJsonFile =
      File('$projectRoot/assets/shen_sha/74_shensha_dizhi_year.json');
  final yearDiZhiJsonString = yearDiZhiJsonFile.readAsStringSync();
  final yearDiZhiList = json.decode(yearDiZhiJsonString) as List;
  List<YearDiZhiShenSha> yearDiZhiShenSha =
      yearDiZhiList.map((e) => YearDiZhiShenSha.fromJson(e)).toList();

  if (yearDiZhiShenSha.any((t) => t.name == "斗杓")) {
    print("----------- 74_shensha_dizhi_year");
  }

  final monthDiZhiJsonFile =
      File('$projectRoot/assets/shen_sha/74_shensha_dizhi_month.json');
  final monthDiZhiJsonString = monthDiZhiJsonFile.readAsStringSync();
  final monthDiZhiList = json.decode(monthDiZhiJsonString) as List;
  List<MonthDiZhiShenSha> monthDiZhiShenSha =
      monthDiZhiList.map((e) => MonthDiZhiShenSha.fromJson(e)).toList();

  final ganzhiJsonFile =
      File('$projectRoot/assets/shen_sha/74_shensha_ganzhi.json');
  final ganzhiJsonString = ganzhiJsonFile.readAsStringSync();
  final ganzhiList = json.decode(ganzhiJsonString) as List;
  List<GanZhiShenSha> ganzhiShenSha =
      ganzhiList.map((e) => GanZhiShenSha.fromJson(e)).toList();

  final bundledShenShaJsonFile =
      File('$projectRoot/assets/shen_sha/74_shensha_bundle.json');
  final bundledShenShaJsonString = bundledShenShaJsonFile.readAsStringSync();
  final bundledShenShaList = json.decode(bundledShenShaJsonString) as List;
  List<BundledShenSha> bundledShenSha =
      bundledShenShaList.map((e) => BundledShenSha.fromJson(e)).toList();

  final otherShenShaJsonFile =
      File('$projectRoot/assets/shen_sha/74_shensha_others.json');
  final otherShenShaJsonString = otherShenShaJsonFile.readAsStringSync();
  final otherShenShaList = json.decode(otherShenShaJsonString) as List;
  List<OtherShenSha> otherShenSha =
      otherShenShaList.map((e) => OtherShenSha.fromJson(e)).toList();

  final fakeRepository = FakeShenShaRepository(
    tianGanShenSha: tianGanShenSha,
    yearDiZhiShenSha: yearDiZhiShenSha,
    monthDiZhiShenSha: monthDiZhiShenSha,
    ganZhiShenSha: ganzhiShenSha,
    bundledShenSha: bundledShenSha,
    otherShenSha: otherShenSha,
  );

  final shenShaService = ShenShaService(repository: fakeRepository);

  final ShenShaManager shenShaManager =
      ShenShaManager(shenShaService: shenShaService);

  group("天干神煞", () {
    // 加载天干神煞数据

    // final ShenShaManager shenShaManager = ShenShaManager(
    // tianGanShenSha: tianGanShenSha,
    // yearDiZhiShenSha: yearDiZhiShenSha,
    // monthDiZhiShenSha: monthDiZhiShenSha);

    test("丁丑年", () async {
      final Map<EnumTwelveGong, List<TianGanShenSha>> resultMapper =
          await shenShaManager.generateTianGanShenShaMapper(JiaZi.DING_CHOU);
      // expect(resultMapper.length, equals(12));
      // expect(resultMapper[EnumTwelveGong.Chou]!.length, equals(1));
      final ganZhiMapper =
          await shenShaManager.generateGanZhiShenShaMapper(JiaZi.DING_CHOU);
      // expect(ganZhiMapper.keys.toSet(), {
      //   EnumTwelveGong.You,
      //   EnumTwelveGong.Mao,
      //   EnumTwelveGong.Shen,
      //   EnumTwelveGong.Wei,
      //   EnumTwelveGong.Yin
      // });
      // expect(ganZhiMapper[EnumTwelveGong.You]!.first.name, equals("空亡"));
      // expect(ganZhiMapper[EnumTwelveGong.Shen]!.first.name, equals("擎天"));
    });
  });

  group("卦气系", () {
    test("卦气", () {
      // （如甲生人昼生，太阳在酉宫，则将甲加在亥上，逆数，甲加亥，乙加戌，丙加酉，酉为太阳所在，即得出丙，丙的禄为巳，则巳宫为卦气所在）
      EnumTwelveGong gong = ShenShaManager.generateGuaQiShenShaMapper(
          JiaZi.JIA_XU,
          EnumTwelveGong.Mao,
          EnumTwelveGong.You,
          EnumTwelveGong.Chou,
          true);
      expect(gong, equals(EnumTwelveGong.Si), reason: gong.name);
    });
  });
  group("斗杓", () {
    test("斗杓", () {
      EnumTwelveGong gong =
          ShenShaManager.generateDouBiao(JiaZi.JI_MAO, JiaZi.WU_WU);
      expect(gong, equals(EnumTwelveGong.Hai), reason: gong.name);
    });
  });

  group("马前诸煞", () {
    test("甲子年 驿马寅", () async {
      final Map<EnumTwelveGong, List<BundledShenSha>> resultMapper =
          await shenShaManager.generateBeforeHorse(
              JiaZi.JIA_ZI,
              bundledShenSha
                  .where((t) => t.type == BundledShenShaType.beforeHorse)
                  .toList());
      expect(resultMapper.length, equals(12));
      expect(resultMapper[EnumTwelveGong.Yin]!.first.name, "驿马");
      expect(resultMapper[EnumTwelveGong.Mao]!.first.name, "六厄");
      expect(resultMapper[EnumTwelveGong.Chen]!.first.name, "华盖");
      expect(resultMapper[EnumTwelveGong.Si]!.first.name, "劫杀");
      expect(resultMapper[EnumTwelveGong.Wu]!.first.name, "灾杀");
      expect(resultMapper[EnumTwelveGong.Wei]!.first.name, "天杀");

      expect(resultMapper[EnumTwelveGong.Shen]!.first.name, "地杀");
      expect(resultMapper[EnumTwelveGong.You]!.first.name, "年杀");
      expect(resultMapper[EnumTwelveGong.Xu]!.first.name, "月杀");
      expect(resultMapper[EnumTwelveGong.Hai]!.first.name, "亡神");
      expect(resultMapper[EnumTwelveGong.Zi]!.first.name, "将星");
      expect(resultMapper[EnumTwelveGong.Chou]!.first.name, "攀鞍");
    });

    test("戊午年 驿马申", () async {
      final Map<EnumTwelveGong, List<BundledShenSha>> resultMapper =
          await shenShaManager.generateBeforeHorse(
              JiaZi.WU_XU,
              bundledShenSha
                  .where((t) => t.type == BundledShenShaType.beforeHorse)
                  .toList());
      expect(resultMapper.length, equals(12));
      expect(resultMapper[EnumTwelveGong.Shen]!.first.name, "驿马");
      expect(resultMapper[EnumTwelveGong.You]!.first.name, "六厄");
      expect(resultMapper[EnumTwelveGong.Xu]!.first.name, "华盖");
      expect(resultMapper[EnumTwelveGong.Hai]!.first.name, "劫杀");
      expect(resultMapper[EnumTwelveGong.Zi]!.first.name, "灾杀");
      expect(resultMapper[EnumTwelveGong.Chou]!.first.name, "天杀");

      expect(resultMapper[EnumTwelveGong.Yin]!.first.name, "地杀");
      expect(resultMapper[EnumTwelveGong.Mao]!.first.name, "年杀");
      expect(resultMapper[EnumTwelveGong.Chen]!.first.name, "月杀");
      expect(resultMapper[EnumTwelveGong.Si]!.first.name, "亡神");
      expect(resultMapper[EnumTwelveGong.Wu]!.first.name, "将星");
      expect(resultMapper[EnumTwelveGong.Wei]!.first.name, "攀鞍");
    });
  });
  group("驾前", () {
    final shenShaStrList = [
      {"剑锋", "伏尸", "岁驾"},
      {"天空", "太阳"},
      {"地雌", "丧门", "地丧"},
      {"太阴", "勾神", "贯索"},
      {"官符", "飞符", "年符", "五鬼"},
      {"月德", "死符", "小耗"},
      {"大耗", "岁破", "阑干"},
      {"龙德", "紫薇", "暴败", "天厄"},
      {"天雄", "白虎"},
      {"天德", "卷舌", "绞杀"},
      {"天狗", "吊客"},
      {"病符", "蓦越"},
    ];
    for (int i = 0; i < 12; i++) {
      final diZhi = DiZhi.values[i];
      test("${diZhi.name}年", () async {
        final Map<EnumTwelveGong, List<BundledShenSha>> resultMapper =
            await shenShaManager.generateBeforeTaiSui(
                EnumTwelveGong.values[i],
                bundledShenSha
                    .where((t) => t.type == BundledShenShaType.beforeJia)
                    .toList());
        expect(resultMapper.length, equals(12));

        final diZhiList = CollectUtils.changeSeq(diZhi, DiZhi.values);
        for (int j = 0; j < 12; j++) {
          final diZhi = diZhiList[j];
          final shenShaStr = shenShaStrList[j];
          // print("${diZhi.name}  ${shenShaStr}");
          expect(
              resultMapper[EnumTwelveGong.getEnumTwelveGongByZhi(diZhi)]!
                  .map((b) => b.name)
                  .toSet(),
              shenShaStr);
        }
      });
    }
  });
  group("驾后", () {
    List<DiZhi> yiMaList = [DiZhi.YIN, DiZhi.SHEN, DiZhi.SI, DiZhi.HAI];
    List<JiaZi> jiaZiList = [
      JiaZi.JIA_ZI,
      JiaZi.WU_XU,
      JiaZi.JI_MAO,
      JiaZi.DING_CHOU
    ];
    List<String> shenShaStrList = [
      "驿马",
      "六厄",
      "华盖",
      "劫杀",
      "灾杀",
      "天杀",
      "地杀",
      "年杀",
      "月杀",
      "亡神",
      "将星",
      "攀鞍"
    ];
    for (int i = 0; i < 4; i++) {
      test("驿马在${yiMaList[i].name}", () async {
        final Map<EnumTwelveGong, List<BundledShenSha>> resultMapper =
            await shenShaManager.generateBeforeHorse(
                jiaZiList[i],
                bundledShenSha
                    .where((t) => t.type == BundledShenShaType.beforeHorse)
                    .toList());
        final DiZhi diZhi = yiMaList[i];
        final List<DiZhi> diZhiList =
            CollectUtils.changeSeq(diZhi, DiZhi.values);
        for (int j = 0; j < 12; j++) {
          // print(shenShaStrList[j]);
          expect(
              resultMapper[EnumTwelveGong.getEnumTwelveGongByZhi(diZhiList[j])]!
                  .first
                  .name,
              shenShaStrList[j]);
        }
      });
    }
  });

  group("干支神煞", () {
    test("乙亥年", () async {
      final Map<EnumTwelveGong, List<ShenSha>> resultMapper =
          await shenShaManager.generateGanZhiShenShaMapper(JiaZi.YI_HAI);
      expect(resultMapper.length, equals(4));
      expect(resultMapper[EnumTwelveGong.Mao]!.first.name, "孤虚");
      expect(resultMapper[EnumTwelveGong.You]!.first.name, "空亡");
      expect(resultMapper[EnumTwelveGong.Zi]!.first.name, "擎天");
      expect(resultMapper[EnumTwelveGong.Wu]!.first.name, "游奕");
    });
  });

  group("神煞", () {
    test("岁殿 丙辰年 午宫", () {
      final suiDian = ShenShaManager.generateSuiDian(JiaZi.BING_CHEN);
      expect(suiDian, equals(EnumTwelveGong.Wu));
    });
    test("岁殿 乙巳年 午宫", () {
      final suiDian = ShenShaManager.generateSuiDian(JiaZi.YI_SI);
      expect(suiDian, equals(EnumTwelveGong.Wu));
    });
    test("岁殿 庚申年 寅宫", () {
      final suiDian = ShenShaManager.generateSuiDian(JiaZi.GENG_SHEN);
      expect(suiDian, equals(EnumTwelveGong.Yin));
    });
    test("月廉 庚辰月 戌宫", () {
      final suiDian = ShenShaManager.generateYueLian(JiaZi.GENG_CHEN);
      expect(suiDian, equals(EnumTwelveGong.Xu));
    });
    test("全部 -", () async {
      final result = await shenShaManager.calculate(
          JiaZi.YI_HAI,
          JiaZi.WU_ZI,
          JiaZi.BING_WU,
          EnumTwelveGong.Zi,
          EnumTwelveGong.Yin,
          EnumTwelveGong.Si,
          true);
      expect(result.length, equals(12));
      result.forEach((key, value) {
        print("${key.name} ${value.map((e) => e.name).toList()}");
      });
    });

    test("全部 - 庚申 庚辰 戊寅 壬子", () async {
      final result = await shenShaManager.calculate(
          JiaZi.GENG_SHEN,
          JiaZi.GENG_CHEN,
          JiaZi.REN_ZI,
          EnumTwelveGong.Zi,
          EnumTwelveGong.You,
          EnumTwelveGong.Wu,
          false);
      expect(result.length, equals(12));
      result.forEach((key, value) {
        print("${key.name} ${value.map((e) => e.name).toList()}");
      });
    });
  });
}

class FakeShenShaRepository implements ShenShaRepository {
  final List<TianGanShenSha> tianGanShenSha;
  final List<YearDiZhiShenSha> yearDiZhiShenSha;
  final List<MonthDiZhiShenSha> monthDiZhiShenSha;
  final List<GanZhiShenSha> ganZhiShenSha;
  final List<BundledShenSha> bundledShenSha;
  final List<OtherShenSha> otherShenSha;

  FakeShenShaRepository({
    required this.tianGanShenSha,
    required this.yearDiZhiShenSha,
    required this.monthDiZhiShenSha,
    required this.ganZhiShenSha,
    required this.bundledShenSha,
    required this.otherShenSha,
  });

  @override
  Future<List<TianGanShenSha>> getTianGanShenSha() async => tianGanShenSha;

  @override
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async =>
      yearDiZhiShenSha;

  @override
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async =>
      monthDiZhiShenSha;

  @override
  Future<List<GanZhiShenSha>> getGanZhiShenSha() async => ganZhiShenSha;

  @override
  Future<List<BundledShenSha>> getBundledShenSha() async => bundledShenSha;

  @override
  Future<List<OtherShenSha>> getOtherShenSha() async => otherShenSha;
}
