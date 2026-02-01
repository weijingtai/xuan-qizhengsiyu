import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';
part 'di_zhi_shen_sha.g.dart';

@JsonSerializable()
class MonthDiZhiShenSha extends DiZhiShenSha {
  MonthDiZhiShenSha(
      String name,
      JiXiongEnum jiXiong,
      List<String> descriptionList,
      List<String> locationDescriptionList,
      Map<DiZhi, DiZhi> locationMapper)
      : super(name, jiXiong, descriptionList, locationDescriptionList,
            locationMapper);

  factory MonthDiZhiShenSha.fromJson(Map<String, dynamic> json) =>
      _$MonthDiZhiShenShaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MonthDiZhiShenShaToJson(this);
}

@JsonSerializable()
class YearDiZhiShenSha extends DiZhiShenSha {
  YearDiZhiShenSha(
      String name,
      JiXiongEnum jiXiong,
      List<String> descriptionList,
      List<String> locationDescriptionList,
      Map<DiZhi, DiZhi> locationMapper)
      : super(name, jiXiong, descriptionList, locationDescriptionList,
            locationMapper);

  factory YearDiZhiShenSha.fromJson(Map<String, dynamic> json) =>
      _$YearDiZhiShenShaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$YearDiZhiShenShaToJson(this);
}

@JsonSerializable()
class JiaZiShenSha extends ShenSha {
  Map<JiaZi, Set<DiZhi>> locationMapper;
  JiaZiShenSha(String name, JiXiongEnum jiXiong, List<String> descriptionList,
      List<String> locationDescriptionList, this.locationMapper)
      : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory JiaZiShenSha.fromJson(Map<String, dynamic> json) =>
      _$JiaZiShenShaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JiaZiShenShaToJson(this);

  // 擎天 神煞
  /// @description 获取擎天神煞于给定年份，所在的地支位置
  // @param yearJiaZi 年干支
  static DiZhi getQingTianAtDiZhi(JiaZi yearJiaZi) {
    return jiaZiShenShaLocationMapper_qingTian[yearJiaZi]!.first;
  }

  // 游奕 神煞
  /// @description 获取游奕神煞于给定年份，所在的地支位置
  // @param yearJiaZi 年干支
  static DiZhi getYouYiAtDiZhi(JiaZi yearJiaZi) {
    // 为擎天神煞的对宫
    return JiaZiShenSha.getQingTianAtDiZhi(yearJiaZi).sixChongZhi;
  }

  // 空亡 神煞
  /// @description 获取空亡煞于给定年份，所在的地支位置
  // @param yearJiaZi 年干支
  static Set<DiZhi>? getKongWangAtDiZhi(JiaZi yearJiaZi) {
    Tuple2<DiZhi, DiZhi> kongWangTuple = yearJiaZi.getKongWang();
    return {kongWangTuple.item1, kongWangTuple.item2};
  }

  // 空亡 神煞
  /// @description 获取游空亡煞于给定年份，所在的地支位置
  // @param yearJiaZi 年支
  static Set<DiZhi>? getGuXuAtDiZhi(JiaZi yearJiaZi) {
    Tuple2<DiZhi, DiZhi> kongWangTuple = yearJiaZi.getKongWang();
    return {kongWangTuple.item1.sixChongZhi, kongWangTuple.item2.sixChongZhi};
  }
}

const Map<JiaZi, Set<DiZhi>> jiaZiShenShaLocationMapper_qingTian = {
  JiaZi.JIA_ZI: {DiZhi.ZI},
  JiaZi.GENG_WU: {DiZhi.ZI},
  JiaZi.YI_HAI: {DiZhi.ZI},
  JiaZi.XIN_SI: {DiZhi.ZI},
  JiaZi.BING_XU: {DiZhi.ZI},
  JiaZi.REN_CHEN: {DiZhi.ZI},
  JiaZi.DING_YOU: {DiZhi.ZI},
  JiaZi.WU_SHEN: {DiZhi.ZI},
  JiaZi.GUI_CHOU: {DiZhi.ZI},
  JiaZi.JI_WEI: {DiZhi.ZI},
  JiaZi.JI_SI: {DiZhi.MAO},
  JiaZi.JIA_XU: {DiZhi.MAO},
  JiaZi.GENG_CHEN: {DiZhi.MAO},
  JiaZi.YI_YOU: {DiZhi.MAO},
  JiaZi.XIN_MAO: {DiZhi.MAO},
  JiaZi.BING_SHEN: {DiZhi.MAO},
  JiaZi.REN_YIN: {DiZhi.MAO},
  JiaZi.DING_WEI: {DiZhi.MAO},
  JiaZi.WU_WU: {DiZhi.MAO},
  JiaZi.GUI_HAI: {DiZhi.MAO},
  JiaZi.GENG_YIN: {DiZhi.CHEN},
  JiaZi.XIN_CHOU: {DiZhi.CHEN},
  JiaZi.REN_ZI: {DiZhi.CHEN},
  JiaZi.WU_CHEN: {DiZhi.SI},
  JiaZi.GUI_YOU: {DiZhi.SI},
  JiaZi.JI_MAO: {DiZhi.SI},
  JiaZi.JIA_SHEN: {DiZhi.SI},
  JiaZi.YI_WEI: {DiZhi.SI},
  JiaZi.BING_WU: {DiZhi.SI},
  JiaZi.DING_SI: {DiZhi.SI},
  JiaZi.JI_CHOU: {DiZhi.WU},
  JiaZi.GENG_ZI: {DiZhi.WU},
  JiaZi.WU_YIN: {DiZhi.WU},
  JiaZi.XIN_HAI: {DiZhi.WU},
  JiaZi.REN_XU: {DiZhi.WU},
  // 乙巳、丁卯、甲午、丙戌、癸未；未
// 丙寅、壬申、丁丑、戊子、己亥、庚戌、辛酉；申
// 癸巳、甲辰、乙卯；酉
// 乙丑、辛未、丙子、壬午、丁亥、戊戌、己酉、甲寅、庚申；戌
// 癸卯；亥
  JiaZi.YI_SI: {DiZhi.WEI},
  JiaZi.DING_MAO: {DiZhi.WEI},
  JiaZi.JIA_WU: {DiZhi.WEI},
  JiaZi.BING_CHEN: {DiZhi.WEI},
  JiaZi.GUI_WEI: {DiZhi.WEI},

  JiaZi.BING_YIN: {DiZhi.SHEN},
  JiaZi.REN_SHEN: {DiZhi.SHEN},
  JiaZi.DING_CHOU: {DiZhi.SHEN},
  JiaZi.WU_ZI: {DiZhi.SHEN},
  JiaZi.JI_HAI: {DiZhi.SHEN},
  JiaZi.GENG_XU: {DiZhi.SHEN},
  JiaZi.XIN_YOU: {DiZhi.SHEN},
  JiaZi.GUI_SI: {DiZhi.YOU},
  JiaZi.JIA_CHEN: {DiZhi.YOU},
  JiaZi.YI_MAO: {DiZhi.YOU},

  JiaZi.YI_CHOU: {DiZhi.XU},
  JiaZi.XIN_WEI: {DiZhi.XU},
  JiaZi.BING_ZI: {DiZhi.XU},
  JiaZi.REN_WU: {DiZhi.XU},
  JiaZi.DING_HAI: {DiZhi.XU},
  JiaZi.WU_XU: {DiZhi.XU},
  JiaZi.JI_YOU: {DiZhi.XU},
  JiaZi.JIA_YIN: {DiZhi.XU},
  JiaZi.GENG_SHEN: {DiZhi.XU},

  JiaZi.GUI_MAO: {DiZhi.HAI},
};
