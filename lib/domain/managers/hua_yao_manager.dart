import 'package:common/enums.dart';
import 'package:common/utils.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:tuple/tuple.dart';

import '../../enums/enum_hua_yao.dart';
import '../../enums/enum_hua_yao_shen_sha.dart';

class HuaYaoManager {
  final HuaYaoService huaYaoService;

  HuaYaoManager({required this.huaYaoService});

  Future<Map<HuaYao, EnumStars>> calculate({
    required EnumTwelveGong mingGong,
    required JiaZi yearJiaZi,
    required JiaZi monthJiaZi,
  }) async {
    final res = <HuaYao, EnumStars>{};
    res.addAll(await generateTianGanHuaYaoBy(yearJiaZi));
    res.addAll(await generateDiZhiHuaYaoBy(yearJiaZi, monthJiaZi));
    res.addAll(await generateOthersHuaYaoBy(
        yearJiaZi: yearJiaZi, mingGong: mingGong));
    return res;
  }

  Future<Map<HuaYao, EnumStars>> generateTianGanHuaYaoBy(JiaZi yearJiaZi) async {
    final res = <HuaYao, EnumStars>{};
    final tianGanHuaYao = await huaYaoService.getTianGanHuaYao();
    tianGanHuaYao.forEach((hy) {
      res[hy] = hy.locationMapper[yearJiaZi.gan]!;
    });
    return res;
  }

  Future<Map<HuaYao, EnumStars>> generateDiZhiHuaYaoBy(
      JiaZi yearJiaZi, JiaZi monthJiaZi) async {
    final res = <HuaYao, EnumStars>{};
    final diZhiHuaYao = await huaYaoService.getDiZhiHuaYao();
    diZhiHuaYao.forEach((hy) {
      if (hy.type == ShenShaType.DiZhi_year) {
        res[hy] = hy.locationMapper[yearJiaZi.zhi]!;
      } else if (hy.type == ShenShaType.DiZhi_month) {
        res[hy] = hy.locationMapper[monthJiaZi.zhi]!;
      }
    });
    return res;
  }

  Future<Map<HuaYao, EnumStars>> generateOthersHuaYaoBy({
    required EnumTwelveGong mingGong,
    required JiaZi yearJiaZi,
  }) async {
    final othersHuaYao = await huaYaoService.getOthersHuaYao();
    Map<HuaYao, EnumStars> res = {};

    // 获取科甲
    final keJia = getKeJia(mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '科甲')] = keJia;

    // 获取人元禄、天元
    final tianJingDiWei = generateTianJingAndDiWei(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '天经')] = tianJingDiWei.item1;
    res[othersHuaYao.firstWhere((e) => e.name == '地纬')] = tianJingDiWei.item2;

    // 获取天元禄
    final tianYuanLu = generateTianYuanLu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '天元禄')] = tianYuanLu;

    // 获取人元禄
    final renYuanLu = generateRenYuanLu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '人元禄')] = renYuanLu;

    // 获取地元禄
    final diYuanLu = generateDiYuanLu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '地元禄')] = diYuanLu;

    // 获取职元
    final zhiYuanAndJuZhu = generateZhiYuanAndJuZhu(yearJiaZi, mingGong);
    res[othersHuaYao.firstWhere((e) => e.name == '职元')] = zhiYuanAndJuZhu[0];
    res[othersHuaYao.firstWhere((e) => e.name == '局主')] = zhiYuanAndJuZhu[1];

    // 获取马元
    final yiMaGong = DiZhiSanHe.getHorseBySingleDiZhi(yearJiaZi.zhi);
    final maYuan =
        generateMaYuan(EnumTwelveGong.getEnumTwelveGongByZhi(yiMaGong));
    res[othersHuaYao.firstWhere((e) => e.name == '马元')] = maYuan;

    // 获取寿元
    final shouYuan = generateShouYuan(yearJiaZi);
    res[othersHuaYao.firstWhere((e) => e.name == '寿元')] = shouYuan;

    return res;
  }

  // Static helper methods
  static EnumStars getKeJia(EnumTwelveGong mingGong) {
    final congFiveXing = mingGong.zhi.sixChongZhi;
    return EnumTwelveGong.getEnumTwelveGongByZhi(congFiveXing).sevenZheng;
  }

  static EnumStars generateRenYuanLu(
    JiaZi yearJiaZi,
    EnumTwelveGong mingGong,
  ) {
    final tigerHead = yearJiaZi.gan.getFiveTiger();
    final countingGongSeq =
        CollectUtils.changeSeq(EnumTwelveGong.Yin, EnumTwelveGong.listAll);
    final countingIndex = countingGongSeq.indexOf(mingGong);

    final countingTianGanSeq =
        CollectUtils.changeSeq(tigerHead, TianGan.listAll);

    final countingTianGan2 = [...countingTianGanSeq, ...countingTianGanSeq];
    final targetGan = countingTianGan2[countingIndex];
    final beiKe = targetGan.fiveXing.beiKe;
    final renYuanStar =
        EnumStars.fiveStars.firstWhere((e) => e.fiveXing == beiKe);

    return renYuanStar;
  }

  static EnumStars generateTianYuanLu(
    JiaZi yearJiaZi,
    EnumTwelveGong mingGong,
  ) {
    final tigerHead = yearJiaZi.gan.getFiveTiger();
    final countingGongSeq =
        CollectUtils.changeSeq(EnumTwelveGong.Yin, EnumTwelveGong.listAll);
    final countingIndex = countingGongSeq.indexOf(mingGong);

    final countingTianGanSeq =
        CollectUtils.changeSeq(tigerHead, TianGan.listAll);

    final countingTianGan2 = [...countingTianGanSeq, ...countingTianGanSeq];
    final targetGan = countingTianGan2[countingIndex];

    return EnumGuoLaoHuaYao.tianGanStarsMapper[targetGan]!;
  }

  static EnumStars generateDiYuanLu(JiaZi yearJiaZi, EnumTwelveGong mingGong) {
    final EnumTwelveGong starFrom =
        EightGua_NaJia_Gong[yearJiaZi.tianGan.naJiaGua]!;
    final starSeq = CollectUtils.changeSeq(
        starFrom, EnumTwelveGong.listAll.reversed.toList());

    final indexAt = starSeq.indexOf(mingGong);
    final tianGanSeq = CollectUtils.changeSeq(yearJiaZi.gan, TianGan.listAll);
    final countingTianGan = [...tianGanSeq, ...tianGanSeq];

    final atTianGan = countingTianGan[indexAt];
    final diYuanLu =
        EnumStars.fiveStars.firstWhere((e) => e.fiveXing == atTianGan.fiveXing);
    return diYuanLu;
  }

  static List<EnumStars> generateZhiYuanAndJuZhu(
      JiaZi yearJiaZi, EnumTwelveGong mingGong) {
    final EnumTwelveGong starFrom =
        EightGua_NaJia_Gong[yearJiaZi.tianGan.naJiaGua]!;
    final starSeq = CollectUtils.changeSeq(starFrom, EnumTwelveGong.listAll);

    final indexAt = starSeq.indexOf(mingGong);
    final tianGanSeq = CollectUtils.changeSeq(yearJiaZi.gan, TianGan.listAll);
    final countingTianGan = [...tianGanSeq, ...tianGanSeq];
    final atTianGan = countingTianGan[indexAt];
    final juZhuTianGan = atTianGan.getOtherTianGanFiveCombine();

    return [
      EnumGuoLaoHuaYao.tianGanStarsMapper[atTianGan]!,
      EnumGuoLaoHuaYao
          .tianGanStarsMapper[atTianGan.getOtherTianGanFiveCombine()]!,
    ];
  }

  static EnumStars generateMaYuan(EnumTwelveGong yiMaGong) {
    return yiMaGong.sevenZheng;
  }

  static EnumStars generateShouYuan(JiaZi yearJiaZi) {
    final FiveXing fiveXing = yearJiaZi.naYin.fiveXing;
    return EnumStars.fiveStars.firstWhere((t) => t.fiveXing == fiveXing);
  }

  static Tuple2<EnumStars, EnumStars> generateTianJingAndDiWei(
      JiaZi yearJiaZi, EnumTwelveGong mingGong) {
    final tigerHead = yearJiaZi.gan.getFiveTiger();
    final countingGongSeq =
        CollectUtils.changeSeq(EnumTwelveGong.Yin, EnumTwelveGong.listAll);
    final countingIndex = countingGongSeq.indexOf(mingGong);

    final countingTianGanSeq =
        CollectUtils.changeSeq(tigerHead, TianGan.listAll);

    final countingTianGan2 = [...countingTianGanSeq, ...countingTianGanSeq];
    final targetGan = countingTianGan2[countingIndex];

    return Tuple2(
        EnumStars.fiveStars.firstWhere((e) => e.fiveXing == targetGan.fiveXing),
        EnumStars.fiveStars
            .firstWhere((e) => e.fiveXing == mingGong.zhi.fiveXing));
  }
}
