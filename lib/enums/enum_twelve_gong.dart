import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

enum EnumDestinyTwelveGong {
  @JsonValue("命宫")
  Ming(0, "命宫", true),
  @JsonValue("财帛")
  CaiBo(1, "财帛", true),
  @JsonValue("兄弟")
  XiongDi(2, "兄弟", false),
  @JsonValue("田宅")
  TianZhai(3, "田宅", true),
  @JsonValue("男女")
  NanNv(4, "男女", false),
  @JsonValue("奴仆")
  NuPu(5, "奴仆", false),
  @JsonValue("夫妻")
  FuQi(6, "夫妻", true),
  @JsonValue("疾厄")
  JiE(7, "疾厄", false),
  @JsonValue("迁移")
  QianYi(8, "迁移", false),
  @JsonValue("官禄")
  GuanLu(9, "官禄", true),
  @JsonValue("福德")
  FuDe(10, "福德", true),
  @JsonValue("相貌")
  XiangMao(11, "相貌", false);

  final int orderedIndex;
  final String name;
  final bool isStrong;
  const EnumDestinyTwelveGong(
    this.orderedIndex,
    this.name,
    this.isStrong,
  );
  static EnumDestinyTwelveGong getEnumDestinyTwelveGongByIndex(int index) {
    return EnumDestinyTwelveGong.values
        .where((e) => e.orderedIndex == index)
        .first;
  }

  static List<EnumDestinyTwelveGong> getOrderedDestinyTwelveGongList() {
    return EnumDestinyTwelveGong.values.toList()
      ..sort((a, b) => a.orderedIndex.compareTo(b.orderedIndex));
  }

  static List<EnumDestinyTwelveGong> getFateOrderedList() {
    return [
      EnumDestinyTwelveGong.Ming,
      EnumDestinyTwelveGong.XiangMao,
      EnumDestinyTwelveGong.FuDe,
      EnumDestinyTwelveGong.GuanLu,
      EnumDestinyTwelveGong.QianYi,
      EnumDestinyTwelveGong.JiE,
      EnumDestinyTwelveGong.FuQi,
      EnumDestinyTwelveGong.NuPu,
      EnumDestinyTwelveGong.NanNv,
      EnumDestinyTwelveGong.TianZhai,
      EnumDestinyTwelveGong.XiongDi,
      EnumDestinyTwelveGong.CaiBo,
    ];
  }
}

enum EnumTwelveGong {
  @JsonValue("子")
  @JsonKey(name: "子")
  Zi(DiZhi.ZI, HouTianGua.Kan, EnumStars.Saturn, TwelveStarSeq.Xuang_Xiao,
      TwelveEclipticGong.AQU, false, YinYang.YANG),
  @JsonValue("丑")
  @JsonKey(name: "丑")
  Chou(DiZhi.CHOU, HouTianGua.Kan, EnumStars.Saturn, TwelveStarSeq.Xing_Ji,
      TwelveEclipticGong.CAP, false, YinYang.YIN),
  @JsonValue("寅")
  @JsonKey(name: "寅")
  Yin(DiZhi.YIN, HouTianGua.Gen, EnumStars.Jupiter, TwelveStarSeq.Xi_Mu,
      TwelveEclipticGong.SAG, false, YinYang.YANG),

  @JsonValue("卯")
  @JsonKey(name: "卯")
  Mao(DiZhi.MAO, HouTianGua.Zhen, EnumStars.Mars, TwelveStarSeq.Da_Huo,
      TwelveEclipticGong.SCO, true, YinYang.YIN),

  @JsonValue("辰")
  @JsonKey(name: "辰")
  Chen(DiZhi.CHEN, HouTianGua.Xun, EnumStars.Venus, TwelveStarSeq.Shou_Xing,
      TwelveEclipticGong.LIB, true, YinYang.YANG),

  @JsonValue("巳")
  @JsonKey(name: "巳")
  Si(DiZhi.SI, HouTianGua.Xun, EnumStars.Mercury, TwelveStarSeq.Chun_Wei,
      TwelveEclipticGong.VIR, true, YinYang.YIN),

  @JsonValue("午")
  @JsonKey(name: "午")
  Wu(DiZhi.WU, HouTianGua.Li, EnumStars.Sun, TwelveStarSeq.Chun_Huo,
      TwelveEclipticGong.LEO, true, YinYang.YANG),
  @JsonValue("未")
  @JsonKey(name: "未")
  Wei(DiZhi.WEI, HouTianGua.Kun, EnumStars.Moon, TwelveStarSeq.Chun_Shou,
      TwelveEclipticGong.CAN, true, YinYang.YIN),
  @JsonValue("申")
  @JsonKey(name: "申")
  Shen(DiZhi.SHEN, HouTianGua.Kun, EnumStars.Mercury, TwelveStarSeq.Shi_Shen,
      TwelveEclipticGong.GEM, true, YinYang.YANG),

  @JsonValue("酉")
  @JsonKey(name: "酉")
  You(DiZhi.YOU, HouTianGua.Dui, EnumStars.Venus, TwelveStarSeq.Da_Liang,
      TwelveEclipticGong.TAU, false, YinYang.YIN),

  @JsonValue("戌")
  @JsonKey(name: "戌")
  Xu(DiZhi.XU, HouTianGua.Qian, EnumStars.Mars, TwelveStarSeq.Jiang_Lou,
      TwelveEclipticGong.ARI, false, YinYang.YANG),

  @JsonValue("亥")
  @JsonKey(name: "亥")
  Hai(DiZhi.HAI, HouTianGua.Qian, EnumStars.Jupiter, TwelveStarSeq.Ju_Zi,
      TwelveEclipticGong.PIS, false, YinYang.YIN);

  final DiZhi zhi;
  final HouTianGua houTianGua;
  final EnumStars sevenZheng;
  final TwelveStarSeq starSeq;
  final TwelveEclipticGong twelveEclipticGong;

  final bool isDayOrNight;
  final YinYang yinYangGong;

  String get name => zhi.name;
  String get fullname =>
      "${zhi.name}${houTianGua.name}${sevenZheng.singleName}";
  static get eclipticSeq =>
      [Xu, You, Shen, Wei, Wu, Si, Chen, Mao, Yin, Chou, Zi, Hai];

  const EnumTwelveGong(this.zhi, this.houTianGua, this.sevenZheng, this.starSeq,
      this.twelveEclipticGong, this.isDayOrNight, this.yinYangGong);
  static EnumTwelveGong getEnumTwelveGongByZhi(DiZhi zhi) {
    return EnumTwelveGong.values.where((e) => e.zhi == zhi).first;
  }

  static EnumTwelveGong fromStrZhi(String zhi) {
    return getEnumTwelveGongByZhi(DiZhi.getFromValue(zhi)!);
  }

  static List<EnumTwelveGong> getSquareGongList(EnumTwelveGong twelveGong,
      [bool withCurrent = false]) {
    // 创建一个新的可修改的Set
    Set<DiZhi> fourSet = DiZhiFourZheng.getBySingleDiZhi(twelveGong.zhi)
        .diZhiSet
        .toSet(); // 通过toSet()创建一个新的可修改Set
    if (!withCurrent) {
      fourSet.remove(twelveGong.zhi);
    }
    return fourSet
        .toList()
        .map((zhi) => EnumTwelveGong.getEnumTwelveGongByZhi(zhi))
        .toList();
  }

  List<EnumTwelveGong> get otherSquareGongList {
    return getSquareGongList(this, false);
  }

  List<EnumTwelveGong> get otherTringleGongList {
    return getTriangleGongList(this, false);
  }

  static List<EnumTwelveGong> getTriangleGongList(EnumTwelveGong twelveGong,
      [bool withCurrent = false]) {
    // 创建一个新的可修改的Set
    Set<DiZhi> sanHeSet = DiZhiSanHe.getBySingleDiZhi(twelveGong.zhi)!
        .content
        .map((e) => e)
        .toSet()
        .toSet(); // 通过两次toSet()创建一个新的可修改Set
    if (!withCurrent) {
      sanHeSet.remove(twelveGong.zhi);
    }
    return sanHeSet
        .toList()
        .map((zhi) => EnumTwelveGong.getEnumTwelveGongByZhi(zhi))
        .toList();
  }

  static List<EnumTwelveGong> get listAll {
    return EnumTwelveGong.values.toList();
  }

  EnumTwelveGong get opposite {
    return EnumTwelveGong.getEnumTwelveGongByZhi(zhi.sixChongZhi);
  }
}
