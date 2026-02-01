import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:common/models/shen_sha_di_zhi.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/models/shen_sha_tian_gan.dart';
import 'package:common/module.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';

import '../../enums/enum_hua_yao_shen_sha.dart';

class ShenShaManager {
  final ShenShaService shenShaService;

  ShenShaManager({required this.shenShaService});

  Future<Map<EnumTwelveGong, List<ShenSha>>> calculate(
      JiaZi yearJiaZi,
      JiaZi monthJiaZi,
      JiaZi hourJiaZi,
      EnumTwelveGong mingGong,
      EnumTwelveGong sunGong,
      EnumTwelveGong moonGong,
      bool isDayBirth) async {
    final result = <EnumTwelveGong, List<ShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      result[e] = [];
    });

    final otherShenSha = await shenShaService.getOtherShenSha();

    // 斗杓
    final douBiaoGong = generateDouBiao(monthJiaZi, hourJiaZi);
    result[douBiaoGong]!.add(otherShenSha.firstWhere((t) => t.name == "斗杓"));

    // 其他神煞 卦气、禄卦(天禄卦气)、岁殿、月廉
    final otherShenShaMapper = await generateOtherShenShaMapper(
        yearJiaZi, monthJiaZi, mingGong, sunGong, moonGong, isDayBirth);
    otherShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 天干神煞 空亡、孤虚、擎天、游奕
    final kongWangGongMapper = await calculateGanZhiShenSha(yearJiaZi);
    kongWangGongMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 驾前、驾后、驿马神煞
    final bundledShenShaMapper = await generateBundledShenSha(yearJiaZi);
    bundledShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 天干神煞
    final tianGanShenShaMapper = await generateTianGanShenShaMapper(yearJiaZi);
    tianGanShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 年 地支神煞
    final yearDiZhiShenShaMapper =
        await generateYearDiZhiShenShaMapper(yearJiaZi);
    yearDiZhiShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 月 地支神煞
    final monthDiZhiShenShaMapper =
        await generateMonthDiZhiShenShaMapper(monthJiaZi);
    monthDiZhiShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });
    return result;
  }

  Future<Map<EnumTwelveGong, List<OtherShenSha>>> generateOtherShenShaMapper(
      JiaZi yearJiaZi,
      JiaZi monthJiaZi,
      EnumTwelveGong mingGong,
      EnumTwelveGong sunGong,
      EnumTwelveGong moonGong,
      bool isDayBirth) async {
    final result = <EnumTwelveGong, List<OtherShenSha>>{};
    final otherShenSha = await shenShaService.getOtherShenSha();

    // 卦气
    final EnumTwelveGong guaQiGong =
        EightGua_NaJia_Gong[yearJiaZi.tianGan.naJiaGua]!;
    result[guaQiGong] = [otherShenSha.firstWhere((t) => t.name == "卦气")];
    // 禄卦
    final luGong = generateGuaQiShenShaMapper(
        yearJiaZi, mingGong, sunGong, moonGong, isDayBirth);
    if (!result.containsKey(luGong)) {
      result[luGong] = [];
    }
    result[luGong]!.add(otherShenSha.firstWhere((t) => t.name == "禄卦"));
    // 岁殿, 从生年年支上起甲，数至生年年干，对应宫位即为岁殿
    final suiDianGong = generateSuiDian(yearJiaZi);
    if (!result.containsKey(suiDianGong)) {
      result[suiDianGong] = [];
    }
    result[suiDianGong]!.add(otherShenSha.firstWhere((t) => t.name == "岁殿"));

    // 月廉
    // 申宫 起正月，顺时针数到生月，对应宫位即为月廉
    final yueLianGong = generateYueLian(monthJiaZi);
    if (!result.containsKey(yueLianGong)) {
      result[yueLianGong] = [];
    }
    result[yueLianGong]!.add(otherShenSha.firstWhere((t) => t.name == "月廉"));
    return result;
  }

  Future<Map<EnumTwelveGong, List<ShenSha>>> calculateGanZhiShenSha(
      JiaZi yearJiaZi) async {
    final result = <EnumTwelveGong, List<ShenSha>>{};
    final ganZhiShenSha = await shenShaService.getGanZhiShenSha();

    ganZhiShenSha.forEach((sh) {
      sh.locationMapper.entries.forEach((e) {
        if (e.value.contains(yearJiaZi)) {
          final gong = EnumTwelveGong.getEnumTwelveGongByZhi(e.key);
          result[gong] = [sh];
        }
      });
    });
    return result;
  }

  Future<Map<EnumTwelveGong, List<TianGanShenSha>>> generateTianGanShenShaMapper(
      JiaZi yearJiaZi) async {
    // 生成天干神煞映射
    final tianGanShenShaMapper = <EnumTwelveGong, List<TianGanShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      tianGanShenShaMapper[e] = [];
    });
    final tianGanShenSha = await shenShaService.getTianGanShenSha();

    for (var i = 0; i < tianGanShenSha.length; i++) {
      final tianGanShenShaItem = tianGanShenSha[i];
      DiZhi atDiZhi = tianGanShenShaItem.locationMapper[yearJiaZi.gan]!;
      tianGanShenShaMapper[EnumTwelveGong.getEnumTwelveGongByZhi(atDiZhi)]!
          .add(tianGanShenShaItem);
    }
    return tianGanShenShaMapper;
  }

  Future<Map<EnumTwelveGong, List<DiZhiShenSha>>>
      generateYearDiZhiShenShaMapper(JiaZi yearJiaZi) async {
    // 生成地支神煞映射
    final yearDiZhiShenShaMapper = <EnumTwelveGong, List<DiZhiShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      yearDiZhiShenShaMapper[e] = [];
    });
    final yearDiZhiShenSha = await shenShaService.getYearDiZhiShenSha();

    for (var i = 0; i < yearDiZhiShenSha.length; i++) {
      final yearDiZhiShenShaItem = yearDiZhiShenSha[i];
      DiZhi atDiZhi = yearDiZhiShenShaItem.locationMapper[yearJiaZi.zhi]!;
      yearDiZhiShenShaMapper[EnumTwelveGong.getEnumTwelveGongByZhi(atDiZhi)]!
          .add(yearDiZhiShenShaItem);
    }

    return yearDiZhiShenShaMapper;
  }

  Future<Map<EnumTwelveGong, List<GanZhiShenSha>>> generateGanZhiShenShaMapper(
      JiaZi yearJiaZi) async {
    // 生成地支神煞映射
    final ganzhiShenShaMapper = <EnumTwelveGong, List<GanZhiShenSha>>{};
    final ganZhiShenSha = await shenShaService.getGanZhiShenSha();
    ganZhiShenSha.forEach((e) {
      e.locationMapper.forEach((key, value) {
        if (value.contains(yearJiaZi)) {
          final gong = EnumTwelveGong.getEnumTwelveGongByZhi(key);
          if (ganzhiShenShaMapper[gong] == null) {
            ganzhiShenShaMapper[gong] = [];
          }
          ganzhiShenShaMapper[gong]!.add(e);
        }
      });
    });
    return ganzhiShenShaMapper;
  }

  Future<Map<EnumTwelveGong, List<DiZhiShenSha>>>
      generateMonthDiZhiShenShaMapper(JiaZi monthJiaZi) async {
    // 生成地支神煞映射
    final monthDiZhiShenShaMapper = <DiZhi, List<DiZhiShenSha>>{};
    final monthDiZhiShenSha = await shenShaService.getMonthDiZhiShenSha();

    DiZhi.listAll.forEach((e) {
      monthDiZhiShenShaMapper[e] = [];
    });

    for (var i = 0; i < monthDiZhiShenSha.length; i++) {
      final monthDiZhiShenShaItem = monthDiZhiShenSha[i];
      DiZhi atDiZhi = monthDiZhiShenShaItem.locationMapper[monthJiaZi.zhi]!;
      monthDiZhiShenShaMapper[atDiZhi]!.add(monthDiZhiShenShaItem);
    }

    // 生成十二宫的地支神煞映射
    return Map.fromEntries(monthDiZhiShenShaMapper.entries.map((entry) {
      return MapEntry(EnumTwelveGong.getEnumTwelveGongByZhi(entry.key),
          entry.value.toList());
    }));
  }

  Future<Map<EnumTwelveGong, List<BundledShenSha>>> generateBundledShenSha(
      JiaZi yearGanZhi) async {
    // 根据年支获得太岁所在位置
    final yearZhi = yearGanZhi.zhi;
    final bundledShenSha = await shenShaService.getBundledShenSha();

    final beforeJiaList = bundledShenSha
        .where((b) => b.type == BundledShenShaType.beforeJia)
        .toList();
    final afterJiaList = bundledShenSha
        .where((b) => b.type == BundledShenShaType.afterJia)
        .toList();
    final beforeHorseSuiList = bundledShenSha
        .where((b) => b.type == BundledShenShaType.beforeHorse)
        .toList();
    final yearTaiSuiGong =
        EnumTwelveGong.getEnumTwelveGongByZhi(yearGanZhi.zhi);
    // 获取驾前
    final beforeJia = generateBeforeTaiSui(yearTaiSuiGong, beforeJiaList);
    final afterJia = generateAfterTaiSui(yearTaiSuiGong, afterJiaList);
    final beforeHorse = generateBeforeHorse(yearGanZhi, beforeHorseSuiList);

    final result = <EnumTwelveGong, List<BundledShenSha>>{};
    for (EnumTwelveGong gong in EnumTwelveGong.listAll) {
      result[gong] = [];
      if (beforeJia.containsKey(gong)) {
        result[gong]!.addAll(beforeJia[gong]!);
      }
      if (afterJia.containsKey(gong)) {
        result[gong]!.addAll(afterJia[gong]!);
      }
      if (beforeHorse.containsKey(gong)) {
        result[gong]!.addAll(beforeHorse[gong]!);
      }
    }
    return result;
  }

  // ... other methods remain static or can be moved to a helper class if they don't depend on the service
  static EnumTwelveGong generateDouBiao(JiaZi monthJiaZi, JiaZi hourJiaZi) {
    // 以戌加在月建宫，顺数至生时即时。
    // 如卯月午时，则戌加在卯，则亥加在辰，子加在巳。。午加亥。则亥为斗标所在。
    final startCountingFromGong =
        EnumTwelveGong.getEnumTwelveGongByZhi(monthJiaZi.zhi);
    final endCountingAt = hourJiaZi.zhi;
    // const starCountingAt = DiZhi.XU;

    final countingTimeZhi = CollectUtils.changeSeq(DiZhi.XU, DiZhi.listAll);
    final targetIndex = countingTimeZhi.indexOf(endCountingAt);
    final countingGongSeq =
        CollectUtils.changeSeq(startCountingFromGong, EnumTwelveGong.listAll);

    return countingGongSeq[targetIndex];
  }

  static EnumTwelveGong generateGuaQiShenShaMapper(
      JiaZi yearJiaZi,
      EnumTwelveGong mingGong,
      EnumTwelveGong sunGong,
      EnumTwelveGong moonGong,
      bool isDayBirth) {
    // 即以年干依纳甲开始，由宫数起。如乾纳壬甲，则甲壬生人，将壬加在亥（即乾）逆数至昼日夜月，看得什么干，此干的禄宫即卦气宫
    // （如甲生人昼生，太阳在酉宫，则将甲加在亥上，逆数，甲加亥，乙加戌，丙加酉，酉为太阳所在，即得出丙，丙的禄为巳，则巳宫为卦气所在）
    // 天禄之余，与禄贵事交切。问对云，官贵命无卦气，安能食天禄。
    final stopCountingGong = isDayBirth ? sunGong : moonGong;
    final startCountingGong = EightGua_NaJia_Gong[yearJiaZi.gan.naJiaGua]!;
    final tianGanFrom = yearJiaZi.gan;
    final countingGongSeq = CollectUtils.changeSeq(
        startCountingGong, EnumTwelveGong.listAll.reversed.toList());
    final countingNnumber = countingGongSeq.indexOf(stopCountingGong);

    final countinTianGanSeq =
        CollectUtils.changeSeq(tianGanFrom, TianGan.listAll);
    final countingTianGan = [...countinTianGanSeq, ...countinTianGanSeq];
    final countinTianGan = countingTianGan[countingNnumber];
    final DiZhi luZhi = TwelveZhangSheng.getLuZhi(countinTianGan);
    final EnumTwelveGong luGong = EnumTwelveGong.getEnumTwelveGongByZhi(luZhi);
    return luGong;
  }

  static EnumTwelveGong generateYueLian(JiaZi monthJiaZi) {
    final gongList =
        CollectUtils.changeSeq(EnumTwelveGong.Shen, EnumTwelveGong.listAll);
    final targetIndex = CollectUtils.changeSeq(DiZhi.YIN, DiZhi.listAll)
        .indexOf(monthJiaZi.diZhi);
    return gongList[targetIndex];
  }

  static EnumTwelveGong generateSuiDian(JiaZi yearJiaZi) {
    final orderedYearZhiSeq =
        CollectUtils.changeSeq(yearJiaZi.diZhi, DiZhi.values);
    final yearGan = yearJiaZi.gan;
    int targetIndex = TianGan.values.indexOf(yearGan);
    DiZhi dizhi = orderedYearZhiSeq[targetIndex];
    final suiDianGong = EnumTwelveGong.getEnumTwelveGongByZhi(dizhi);
    return suiDianGong;
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateBeforeTaiSui(
      EnumTwelveGong taiSui, List<BundledShenSha> shenShaList) {
    Map<EnumTwelveGong, List<BundledShenSha>> result = {};
    final taiSuiAt = taiSui.zhi.index;
    shenShaList.forEach((e) {
      int index = (e.offset + taiSuiAt) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      if (!result.containsKey(gong)) {
        result[gong] = [];
      }
      result[gong]!.add(e);
    });
    return result;
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateAfterTaiSui(
      EnumTwelveGong taiSui, List<BundledShenSha> shenShaList) {
    Map<EnumTwelveGong, List<BundledShenSha>> result = {};
    final taiSuiAt = taiSui.zhi.index;
    // 红鸾
    int hongLuanAtDiZhiIndex =
        EnumAfterTaiSuiShenSha.getHongLuanPositionByDiZhiOrder(taiSuiAt);

    DiZhi hongLuanAtDiZhi = DiZhi.getByOrder(hongLuanAtDiZhiIndex + 1);

    // 红鸾
    shenShaList.whereNot((t) => t.name == "红鸾").forEach((e) {
      int index = (e.offset + hongLuanAtDiZhiIndex) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      if (!result.containsKey(gong)) {
        result[gong] = [];
      }
      result[gong]!.add(e);
    });

    // 红鸾位置
    EnumTwelveGong hongLuanAtGong = EnumTwelveGong.getEnumTwelveGongByZhi(
        DiZhi.getByOrder(hongLuanAtDiZhiIndex + 1));

    BundledShenSha hongLuan = shenShaList.firstWhere((t) => t.name == "红鸾");

    if (!result.containsKey(hongLuanAtGong)) {
      result[hongLuanAtGong] = [];
    }
    result[hongLuanAtGong]!.add(hongLuan);
    return result;
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateBeforeHorse(
      JiaZi yearGanZhi, List<BundledShenSha> beforeHorseList) {
    final yearHouseDiZhi = DiZhiSanHe.getHorseBySingleDiZhi(yearGanZhi.zhi);
    final yearHouseGong = EnumTwelveGong.getEnumTwelveGongByZhi(yearHouseDiZhi);

    Map<EnumTwelveGong, List<BundledShenSha>> result = {};
    beforeHorseList.forEach((e) {
      int index = (e.offset + yearHouseGong.index) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      result[gong] = [e];
    });
    return result;
  }
}
