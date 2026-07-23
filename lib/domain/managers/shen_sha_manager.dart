import 'package:collection/collection.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/shen_sha_di_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:metaphysics_core/models/shen_sha.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/twelve_zhang_sheng.dart';
import 'package:metaphysics_core/utils/collections_utils.dart';
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
    final otherShenSha = await shenShaService.getOtherShenSha();
    final ganZhiShenSha = await shenShaService.getGanZhiShenSha();
    final tianGanShenSha = await shenShaService.getTianGanShenSha();
    final yearDiZhiShenSha = await shenShaService.getYearDiZhiShenSha();
    final monthDiZhiShenSha = await shenShaService.getMonthDiZhiShenSha();
    final bundledShenSha = await shenShaService.getBundledShenSha();
    return calculateShenShaSync(
      yearJiaZi: yearJiaZi,
      monthJiaZi: monthJiaZi,
      hourJiaZi: hourJiaZi,
      mingGong: mingGong,
      sunGong: sunGong,
      moonGong: moonGong,
      isDayBirth: isDayBirth,
      otherShenSha: otherShenSha,
      ganZhiShenSha: ganZhiShenSha,
      tianGanShenSha: tianGanShenSha,
      yearDiZhiShenSha: yearDiZhiShenSha,
      monthDiZhiShenSha: monthDiZhiShenSha,
      bundledShenSha: bundledShenSha,
    );
  }

  Future<Map<EnumTwelveGong, List<TianGanShenSha>>> generateTianGanShenShaMapper(
      JiaZi yearJiaZi) async {
    final tianGanShenSha = await shenShaService.getTianGanShenSha();
    return _generateTianGanShenShaMapperSync(yearJiaZi, tianGanShenSha);
  }

  Future<Map<EnumTwelveGong, List<GanZhiShenSha>>> generateGanZhiShenShaMapper(
      JiaZi yearJiaZi) async {
    final mapper = <EnumTwelveGong, List<GanZhiShenSha>>{};
    final ganZhiShenSha = await shenShaService.getGanZhiShenSha();
    ganZhiShenSha.forEach((e) {
      e.locationMapper.forEach((key, value) {
        if (value.contains(yearJiaZi)) {
          final gong = EnumTwelveGong.getEnumTwelveGongByZhi(key);
          mapper[gong] = [...?mapper[gong], e];
        }
      });
    });
    return mapper;
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateBeforeHorse(
    JiaZi yearGanZhi, List<BundledShenSha> beforeHorseList) {
    return _generateBeforeHorseStatic(yearGanZhi, beforeHorseList);
  }

  Map<EnumTwelveGong, List<BundledShenSha>> generateBeforeTaiSui(
    EnumTwelveGong taiSui, List<BundledShenSha> shenShaList) {
    return _generateBeforeTaiSuiStatic(taiSui, shenShaList);
  }

  static Map<EnumTwelveGong, List<ShenSha>> calculateShenShaSync({
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
    required JiaZi hourJiaZi,
    required EnumTwelveGong mingGong,
    required EnumTwelveGong sunGong,
    required EnumTwelveGong moonGong,
    required bool isDayBirth,
    required List<OtherShenSha> otherShenSha,
    required List<GanZhiShenSha> ganZhiShenSha,
    required List<TianGanShenSha> tianGanShenSha,
    required List<DiZhiShenSha> yearDiZhiShenSha,
    required List<DiZhiShenSha> monthDiZhiShenSha,
    required List<BundledShenSha> bundledShenSha,
  }) {
    final result = <EnumTwelveGong, List<ShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      result[e] = [];
    });

    // 斗杓
    final douBiaoGong = generateDouBiao(monthJiaZi, hourJiaZi);
    result[douBiaoGong]!.add(otherShenSha.firstWhere((t) => t.name == "斗杓"));

    // 其他神煞 卦气、禄卦、岁殿、月廉
    final otherShenShaMapper = _generateOtherShenShaMapperSync(
        yearJiaZi, monthJiaZi, mingGong, sunGong, moonGong, isDayBirth, otherShenSha);
    otherShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 天干神煞 空亡、孤虚、擎天、游奕
    final kongWangGongMapper = _calculateGanZhiShenShaSync(yearJiaZi, ganZhiShenSha);
    kongWangGongMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 驾前、驾后、驿马神煞
    final bundledShenShaMapper = _generateBundledShenShaSync(yearJiaZi, bundledShenSha);
    bundledShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 天干神煞
    final tianGanShenShaMapper = _generateTianGanShenShaMapperSync(yearJiaZi, tianGanShenSha);
    tianGanShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 年 地支神煞
    final yearDiZhiShenShaMapper = _generateYearDiZhiShenShaMapperSync(yearJiaZi, yearDiZhiShenSha);
    yearDiZhiShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });

    // 月 地支神煞
    final monthDiZhiShenShaMapper = _generateMonthDiZhiShenShaSync(monthJiaZi, monthDiZhiShenSha);
    monthDiZhiShenShaMapper.forEach((key, value) {
      result[key]!.addAll(value);
    });
    return result;
  }

  static Map<EnumTwelveGong, List<OtherShenSha>> _generateOtherShenShaMapperSync(
      JiaZi yearJiaZi,
      JiaZi monthJiaZi,
      EnumTwelveGong mingGong,
      EnumTwelveGong sunGong,
      EnumTwelveGong moonGong,
      bool isDayBirth,
      List<OtherShenSha> otherShenSha) {
    final result = <EnumTwelveGong, List<OtherShenSha>>{};

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

  static Map<EnumTwelveGong, List<ShenSha>> _calculateGanZhiShenShaSync(
      JiaZi yearJiaZi, List<GanZhiShenSha> ganZhiShenSha) {
    final result = <EnumTwelveGong, List<ShenSha>>{};
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

  static Map<EnumTwelveGong, List<TianGanShenSha>> _generateTianGanShenShaMapperSync(
      JiaZi yearJiaZi, List<TianGanShenSha> tianGanShenSha) {
    final tianGanShenShaMapper = <EnumTwelveGong, List<TianGanShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      tianGanShenShaMapper[e] = [];
    });

    for (var i = 0; i < tianGanShenSha.length; i++) {
      final item = tianGanShenSha[i];
      DiZhi atDiZhi = item.locationMapper[yearJiaZi.gan]!;
      tianGanShenShaMapper[EnumTwelveGong.getEnumTwelveGongByZhi(atDiZhi)]!
          .add(item);
    }
    return tianGanShenShaMapper;
  }

  static Map<EnumTwelveGong, List<DiZhiShenSha>> _generateYearDiZhiShenShaMapperSync(
      JiaZi yearJiaZi, List<DiZhiShenSha> yearDiZhiShenSha) {
    final mapper = <EnumTwelveGong, List<DiZhiShenSha>>{};
    EnumTwelveGong.listAll.forEach((e) {
      mapper[e] = [];
    });

    for (var i = 0; i < yearDiZhiShenSha.length; i++) {
      final item = yearDiZhiShenSha[i];
      DiZhi atDiZhi = item.locationMapper[yearJiaZi.zhi]!;
      mapper[EnumTwelveGong.getEnumTwelveGongByZhi(atDiZhi)]!.add(item);
    }
    return mapper;
  }

  static Map<EnumTwelveGong, List<DiZhiShenSha>> _generateMonthDiZhiShenShaSync(
      JiaZi monthJiaZi, List<DiZhiShenSha> monthDiZhiShenSha) {
    final diZhiMapper = <DiZhi, List<DiZhiShenSha>>{};
    DiZhi.listAll.forEach((e) {
      diZhiMapper[e] = [];
    });

    for (var i = 0; i < monthDiZhiShenSha.length; i++) {
      final item = monthDiZhiShenSha[i];
      DiZhi atDiZhi = item.locationMapper[monthJiaZi.zhi]!;
      diZhiMapper[atDiZhi]!.add(item);
    }

    return Map.fromEntries(diZhiMapper.entries.map((entry) {
      return MapEntry(EnumTwelveGong.getEnumTwelveGongByZhi(entry.key),
          entry.value.toList());
    }));
  }

  static Map<EnumTwelveGong, List<BundledShenSha>> _generateBundledShenShaSync(
      JiaZi yearGanZhi, List<BundledShenSha> bundledShenSha) {
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

    final beforeJia = _generateBeforeTaiSuiStatic(yearTaiSuiGong, beforeJiaList);
    final afterJia = generateAfterTaiSui(yearTaiSuiGong, afterJiaList);
    final beforeHorse = _generateBeforeHorseStatic(yearGanZhi, beforeHorseSuiList);

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

  static Map<EnumTwelveGong, List<BundledShenSha>> _generateBeforeTaiSuiStatic(
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

  static Map<EnumTwelveGong, List<BundledShenSha>> generateAfterTaiSui(
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

  static Map<EnumTwelveGong, List<BundledShenSha>> _generateBeforeHorseStatic(
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
