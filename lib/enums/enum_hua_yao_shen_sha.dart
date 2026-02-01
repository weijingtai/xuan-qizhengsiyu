import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_gong_info.dart';

enum ShenShaType {
  @JsonValue('天干')
  TianGan,
  @JsonValue('年地支')
  DiZhi_year,
  @JsonValue('月地支')
  DiZhi_month,
  @JsonValue('命宫')
  MingGong,
  @JsonValue('纳音')
  NaYin,
  @JsonValue('纳甲')
  NaJia,
  @JsonValue('其他')
  Others,
  @JsonValue('果老')
  GuoLao,
}

enum EnumHuaYaoShenSha {
// - 科名，接近权贵，名为高重。不仅限于科考
// - 科甲，能听人劝而得到成就地位，
// - 文星，学习能力强，五行相济而成文也。如果身星也旺，那么命主贵。
// - 魁星，第一名。士子用之主名高位重，庶人有之亦有声望。主勇争第一，不论什么行业
// - 官星。官运，官星强在事业上自然而然有成就，先天的官星。
// - 印星。
// - 寿元，命元，纳音星。寿元克命不为忌
// - 催官，增强官禄宫能量。有利于官印和事业发展。
// - 禄神，主俸禄
// - 喜神，主喜气
// - 爵神，主进爵
// - 天马、地驿，天马多主升迁，地驿多主平级工作调动
// - 马元，驿马星所在宫位
// - 天元，先天出生时所带的禀赋
// - 地元，所处大环境能量
// - 人元，自身潜力
// - 仁元，基本不看
// - 血支，基本不看
// - 血忌，基本不看
// - 产星，基本不看
// - 生官，类似正财
// - 值难，凶星，根据季节变换，逢之主凶。遇凶更凶，最怕克命，太岁填实
// - 职元，主职分
// - 局主，根据职元来定。
// - 天经、地纬，果老派重视，天经地纬拱夹星、宫能量最好，带来吉利
// - 伤官，阳年化天耗，阴年化天暗

  KeMing('科名', ShenShaType.TianGan),
  WenXing('文星', ShenShaType.TianGan),

  KuiXing('魁星', ShenShaType.TianGan),
  GuanXing('官星', ShenShaType.TianGan),
  YinXing('印星', ShenShaType.TianGan),
  CuiGuan('催官', ShenShaType.TianGan),
  LuShen('禄神', ShenShaType.TianGan),
  XiShen('喜神', ShenShaType.TianGan),
  ShangGuan('伤官', ShenShaType.TianGan),
  ShengGuan('生官', ShenShaType.TianGan),
  TianSi("天嗣", ShenShaType.TianGan),
  TianGuan("天官", ShenShaType.TianGan),
  LuYuan('禄元', ShenShaType.TianGan),
  RenDeYuan('仁元', ShenShaType.TianGan),

  ShouYuan('寿元', ShenShaType.NaYin),

  GuaQi('卦气', ShenShaType.NaJia),

  JuGuan('局主', ShenShaType.Others),
  MaYuan('马元', ShenShaType.Others),

  KeJia('科甲', ShenShaType.MingGong), // 命宫对宫的宫主星为科甲。
  ZhiYuan('职元', ShenShaType.MingGong),
  TianJing('天经', ShenShaType.MingGong),
  DiWei('地纬', ShenShaType.MingGong),
  TianYuan('天元', ShenShaType.MingGong),
  DiYuan('地元', ShenShaType.MingGong),
  RenYuan('人元', ShenShaType.MingGong),
  // 地支
  XueZhi('血支', ShenShaType.DiZhi_year),
  XueJi('血忌', ShenShaType.DiZhi_year),
  ChanXing('产星', ShenShaType.DiZhi_year),
  TianMa('天马', ShenShaType.DiZhi_year),
  DiYi('地驿', ShenShaType.DiZhi_year),
  JueShen('爵神', ShenShaType.DiZhi_year),

  ZhiNan('值难', ShenShaType.DiZhi_month); // 以月支定， 其他都为年

  final String name;
  final ShenShaType type;
  const EnumHuaYaoShenSha(this.name, this.type);

  static Set<EnumHuaYaoShenSha> starIsYearGanShenSha(
      TianGan yearGan, EnumStars star) {
    Set<EnumHuaYaoShenSha> result = {};
    if (isTianSi(yearGan, star) != null) {
      result.add(TianSi);
    }
    if (isTianGuan(yearGan, star) != null) {
      result.add(TianGuan);
    }
    if (isLuYuan(yearGan, star) != null) {
      result.add(LuYuan);
    }
    if (isRenDeYuan(yearGan, star) != null) {
      result.add(RenDeYuan);
    }

    if (isKeMing(yearGan, star) != null) {
      result.add(KeMing);
    }
    if (isWenXing(yearGan, star) != null) {
      result.add(WenXing);
    }
    if (isKuiXing(yearGan, star) != null) {
      result.add(KuiXing);
    }
    if (isYinXing(yearGan, star) != null) {
      result.add(YinXing);
    }
    if (isCuiGuan(yearGan, star) != null) {
      result.add(CuiGuan);
    }

    if (isLuShen(yearGan, star) != null) {
      result.add(LuShen);
    }
    if (isXiShen(yearGan, star) != null) {
      result.add(XiShen);
    }

    if (isShangGuan(yearGan, star) != null) {
      result.add(ShangGuan);
    }
    if (isShengGuan(yearGan, star) != null) {
      result.add(ShengGuan);
    }

    return result;
  }

  static Set<EnumHuaYaoShenSha> starIsYearZhiShenSha(
      DiZhi yearZhi, EnumStars star) {
    Set<EnumHuaYaoShenSha> result = {};
    if (isJueShen(yearZhi, star) != null) {
      result.add(JueShen);
    }
    if (isXueZhi(yearZhi, star) != null) {
      result.add(XueZhi);
    }
    if (isXueJi(yearZhi, star) != null) {
      result.add(XueJi);
    }
    if (isChanXing(yearZhi, star) != null) {
      result.add(ChanXing);
    }
    if (isTianMa(yearZhi, star) != null) {
      result.add(TianMa);
    }
    if (isDiYi(yearZhi, star) != null) {
      result.add(DiYi);
    }

    return result;
  }

  /// 文星
  static EnumHuaYaoShenSha? isWenXing(TianGan yearGan, EnumStars star) {
    /// 甲罗乙计丙戊金，丁火己气庚木星，辛人见土壬逢日，癸人见月定昌荣
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Luo,
      TianGan.YI: EnumStars.Ji,
      TianGan.BING: EnumStars.Venus,
      TianGan.WU: EnumStars.Venus,
      TianGan.DING: EnumStars.Mars,
      TianGan.JI: EnumStars.Qi,
      TianGan.GENG: EnumStars.Jupiter,
      TianGan.XIN: EnumStars.Saturn,
      TianGan.REN: EnumStars.Sun,
      TianGan.GUI: EnumStars.Moon,
    };
    return mapper[yearGan] == star ? EnumHuaYaoShenSha.WenXing : null;
  }

  /// 魁星
  static EnumHuaYaoShenSha? isKuiXing(TianGan yearGan, EnumStars star) {
    // 甲用太阴乙太阳，丙罗丁计戊炎方,己金庚水辛逢孛，壬气癸水号魁光
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Moon,
      TianGan.YI: EnumStars.Sun,
      TianGan.BING: EnumStars.Luo,
      TianGan.WU: EnumStars.Mars,
      TianGan.DING: EnumStars.Ji,
      TianGan.JI: EnumStars.Venus,
      TianGan.GENG: EnumStars.Jupiter,
      TianGan.XIN: EnumStars.Bei,
      TianGan.REN: EnumStars.Qi,
      TianGan.GUI: EnumStars.Mercury,
    };
    mapper[yearGan] == star ? EnumHuaYaoShenSha.KuiXing : null;
    return null;
  }

  /// 科名
  static EnumHuaYaoShenSha? isKeMing(TianGan yearGan, EnumStars star) {
    if (star.isFiveStar && ![EnumStars.Sun, EnumStars.Moon].contains(star)) {
      if (star.fiveXing == yearGan.fiveXing) {
        return EnumHuaYaoShenSha.KeMing;
      }
    }
    return null;
  }

  /// 官星
  static EnumHuaYaoShenSha? isGuanXing(TianGan yearGan, EnumStars star) {
    // 甲气乙水是官星，丙罗丁计戊孛成，己土庚金辛见木，壬阴癸土定功名
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Qi,
      TianGan.YI: EnumStars.Mercury,
      TianGan.BING: EnumStars.Luo,
      TianGan.DING: EnumStars.Ji,
      TianGan.WU: EnumStars.Bei,
      TianGan.JI: EnumStars.Saturn,
      TianGan.GENG: EnumStars.Venus,
      TianGan.XIN: EnumStars.Jupiter,
      TianGan.REN: EnumStars.Moon,
      TianGan.GUI: EnumStars.Saturn,
    };
    return mapper[yearGan] == star ? EnumHuaYaoShenSha.GuanXing : null;
  }

  /// 印星
  static EnumHuaYaoShenSha? isYinXing(TianGan yearGan, EnumStars star) {
    // 甲木乙日丙是荧，丁月戊土己罗辰，庚金辛计壬逢水，癸人见孛是印星
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Jupiter,
      TianGan.YI: EnumStars.Sun,
      TianGan.BING: EnumStars.Mars,
      TianGan.DING: EnumStars.Moon,
      TianGan.WU: EnumStars.Saturn,
      TianGan.JI: EnumStars.Luo,
      TianGan.GENG: EnumStars.Venus,
      TianGan.XIN: EnumStars.Ji,
      TianGan.REN: EnumStars.Mercury,
      TianGan.GUI: EnumStars.Bei,
    };
    return mapper[yearGan] == star ? EnumHuaYaoShenSha.YinXing : null;
  }

  /// 催官
  static EnumHuaYaoShenSha? isCuiGuan(TianGan yearGan, EnumStars star) {
    // 甲金乙水丙日宣，丁罗戊木见为欢，己气庚孛辛土宿，壬月癸计是催官
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Venus,
      TianGan.YI: EnumStars.Mercury,
      TianGan.BING: EnumStars.Sun,
      TianGan.DING: EnumStars.Luo,
      TianGan.WU: EnumStars.Jupiter,
      TianGan.JI: EnumStars.Qi,
      TianGan.GENG: EnumStars.Bei,
      TianGan.XIN: EnumStars.Saturn,
      TianGan.REN: EnumStars.Moon,
      TianGan.GUI: EnumStars.Ji
    };

    return mapper[yearGan] == star ? EnumHuaYaoShenSha.CuiGuan : null;
  }

  /// 禄神
  static EnumHuaYaoShenSha? isLuShen(TianGan yearGan, EnumStars star) {
    // 甲兼木孛乙水星，丙计丁罗戊土居，己火庚金辛紫气，壬日癸月是禄神
    Map<TianGan, Set<EnumStars>> mapper = {
      TianGan.JIA: {EnumStars.Jupiter, EnumStars.Bei},
      TianGan.YI: {EnumStars.Mercury},
      TianGan.BING: {EnumStars.Ji},
      TianGan.DING: {EnumStars.Luo},
      TianGan.WU: {EnumStars.Saturn},
      TianGan.JI: {EnumStars.Mars},
      TianGan.GENG: {EnumStars.Venus},
      TianGan.XIN: {EnumStars.Qi},
      TianGan.REN: {EnumStars.Sun},
      TianGan.GUI: {EnumStars.Moon}
    };

    return mapper[yearGan]!.contains(star) ? EnumHuaYaoShenSha.LuShen : null;
  }

  /// 禄元
  static EnumHuaYaoShenSha? isLuYuan(TianGan yearGan, EnumStars star) {
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Jupiter,
      TianGan.YI: EnumStars.Mars,
      TianGan.BING: EnumStars.Mercury,
      TianGan.DING: EnumStars.Sun,
      TianGan.WU: EnumStars.Mercury,
      TianGan.JI: EnumStars.Sun,
      TianGan.GENG: EnumStars.Mercury,
      TianGan.XIN: EnumStars.Venus,
      TianGan.REN: EnumStars.Jupiter,
      TianGan.GUI: EnumStars.Saturn
    };

    return mapper[yearGan]! == star ? EnumHuaYaoShenSha.LuYuan : null;
  }

  /// 仁元
  static EnumHuaYaoShenSha? isRenDeYuan(TianGan yearGan, EnumStars star) {
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Jupiter,
      TianGan.YI: EnumStars.Jupiter,
      TianGan.BING: EnumStars.Mars,
      TianGan.DING: EnumStars.Mars,
      TianGan.WU: EnumStars.Saturn,
      TianGan.JI: EnumStars.Saturn,
      TianGan.GENG: EnumStars.Venus,
      TianGan.XIN: EnumStars.Venus,
      TianGan.REN: EnumStars.Mercury,
      TianGan.GUI: EnumStars.Mercury
    };

    return mapper[yearGan]! == star ? EnumHuaYaoShenSha.RenYuan : null;
  }

  /// 喜神
  static EnumHuaYaoShenSha? isXiShen(TianGan yearGan, EnumStars star) {
    // 甲罗乙计丙气星，丁水戊月是喜神，己土庚金辛见水，壬孛癸火最堪亲
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Luo,
      TianGan.YI: EnumStars.Ji,
      TianGan.BING: EnumStars.Qi,
      TianGan.DING: EnumStars.Mercury,
      TianGan.WU: EnumStars.Moon,
      TianGan.JI: EnumStars.Saturn,
      TianGan.GENG: EnumStars.Venus,
      TianGan.XIN: EnumStars.Mercury,
      TianGan.REN: EnumStars.Bei,
      TianGan.GUI: EnumStars.Mars
    };

    return mapper[yearGan]! == star ? EnumHuaYaoShenSha.XiShen : null;
  }

  /// 天嗣
  static EnumHuaYaoShenSha? isTianSi(TianGan yearGan, EnumStars star) {
    // 甲月乙水丙气余，丁计戊罗己火居，庚孛辛木壬金宿，癸人见土是天嗣
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Moon,
      TianGan.YI: EnumStars.Mercury,
      TianGan.BING: EnumStars.Qi,
      TianGan.DING: EnumStars.Ji,
      TianGan.WU: EnumStars.Luo,
      TianGan.JI: EnumStars.Mars,
      TianGan.GENG: EnumStars.Bei,
      TianGan.XIN: EnumStars.Jupiter,
      TianGan.REN: EnumStars.Venus,
      TianGan.GUI: EnumStars.Saturn
    };

    return mapper[yearGan]! == star ? EnumHuaYaoShenSha.TianSi : null;
  }

  /// 天官
  static EnumHuaYaoShenSha? isTianGuan(TianGan yearGan, EnumStars star) {
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Qi,
      TianGan.YI: EnumStars.Mercury,
      TianGan.BING: EnumStars.Luo,
      TianGan.DING: EnumStars.Ji,
      TianGan.WU: EnumStars.Bei,
      TianGan.JI: EnumStars.Mars,
      TianGan.GENG: EnumStars.Venus,
      TianGan.XIN: EnumStars.Jupiter,
      TianGan.REN: EnumStars.Moon,
      TianGan.GUI: EnumStars.Saturn
    };

    return mapper[yearGan]! == star ? EnumHuaYaoShenSha.TianGuan : null;
  }

  /// 生官
  static EnumHuaYaoShenSha? isShengGuan(TianGan yearGan, EnumStars star) {
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Moon,
      TianGan.YI: EnumStars.Saturn,
      TianGan.BING: EnumStars.Qi,
      TianGan.DING: EnumStars.Mercury,
      TianGan.WU: EnumStars.Luo,
      TianGan.JI: EnumStars.Ji,
      TianGan.GENG: EnumStars.Bei,
      TianGan.XIN: EnumStars.Mars,
      TianGan.REN: EnumStars.Venus,
      TianGan.GUI: EnumStars.Jupiter
    };

    return mapper[yearGan]! == star ? EnumHuaYaoShenSha.ShengGuan : null;
  }

  /// 生官
  static EnumHuaYaoShenSha? isShangGuan(TianGan yearGan, EnumStars star) {
    Map<TianGan, EnumStars> mapper = {
      TianGan.JIA: EnumStars.Venus,
      TianGan.YI: EnumStars.Jupiter,
      TianGan.BING: EnumStars.Moon,
      TianGan.DING: EnumStars.Saturn,
      TianGan.WU: EnumStars.Qi,
      TianGan.JI: EnumStars.Mercury,
      TianGan.GENG: EnumStars.Luo,
      TianGan.XIN: EnumStars.Ji,
      TianGan.REN: EnumStars.Bei,
      TianGan.GUI: EnumStars.Mars
    };

    return mapper[yearGan]! == star ? EnumHuaYaoShenSha.ShangGuan : null;
  }

  /// 爵神
  /// 地支
  static EnumHuaYaoShenSha? isJueShen(DiZhi yearZhi, EnumStars star) {
    Map<DiZhi, EnumStars> mapper = {
      DiZhi.ZI: EnumStars.Saturn,
      DiZhi.SHEN: EnumStars.Saturn,
      DiZhi.HAI: EnumStars.Mars,
      DiZhi.WEI: EnumStars.Mars,
      DiZhi.WU: EnumStars.Mercury,
      DiZhi.CHOU: EnumStars.Mercury,
      DiZhi.MAO: EnumStars.Qi,
      DiZhi.YIN: EnumStars.Jupiter,
      DiZhi.SI: EnumStars.Jupiter,
      DiZhi.YOU: EnumStars.Venus,
      DiZhi.XU: EnumStars.Venus,
      DiZhi.CHEN: EnumStars.Bei
    };
    return mapper[yearZhi]! == star ? EnumHuaYaoShenSha.JueShen : null;
  }

  /// 天马
  static EnumHuaYaoShenSha? isTianMa(DiZhi yearZhi, EnumStars star) {
    Map<DiZhi, EnumStars> mapper = {
      DiZhi.ZI: EnumStars.Mars,
      DiZhi.SHEN: EnumStars.Mars,
      DiZhi.CHEN: EnumStars.Mars,
      DiZhi.HAI: EnumStars.Jupiter,
      DiZhi.WEI: EnumStars.Jupiter,
      DiZhi.MAO: EnumStars.Jupiter,
      DiZhi.WU: EnumStars.Mercury,
      DiZhi.YIN: EnumStars.Mercury,
      DiZhi.XU: EnumStars.Mercury,
      DiZhi.SI: EnumStars.Ji,
      DiZhi.YOU: EnumStars.Ji,
      DiZhi.CHOU: EnumStars.Ji,
    };

    return mapper[yearZhi]! == star ? EnumHuaYaoShenSha.TianMa : null;
  }

  // 地驿
  static EnumHuaYaoShenSha? isDiYi(DiZhi yearZhi, EnumStars star) {
    Map<DiZhi, EnumStars> mapper = {
      DiZhi.ZI: EnumStars.Jupiter,
      DiZhi.CHOU: EnumStars.Mercury,
      DiZhi.YIN: EnumStars.Venus,
      DiZhi.MAO: EnumStars.Mars,
      DiZhi.CHEN: EnumStars.Jupiter,
      DiZhi.SI: EnumStars.Mercury,
      DiZhi.WU: EnumStars.Venus,
      DiZhi.WEI: EnumStars.Mars,
      DiZhi.SHEN: EnumStars.Jupiter,
      DiZhi.YOU: EnumStars.Mercury,
      DiZhi.XU: EnumStars.Venus,
      DiZhi.HAI: EnumStars.Mars,
    };

    return mapper[yearZhi]! == star ? EnumHuaYaoShenSha.DiYi : null;
  }

  // 血支
  static EnumHuaYaoShenSha? isXueZhi(DiZhi yearZhi, EnumStars star) {
    Map<DiZhi, EnumStars> mapper = {
      DiZhi.ZI: EnumStars.Jupiter,
      DiZhi.CHOU: EnumStars.Saturn,
      DiZhi.YIN: EnumStars.Saturn,
      DiZhi.MAO: EnumStars.Jupiter,
      DiZhi.CHEN: EnumStars.Mars,
      DiZhi.SI: EnumStars.Venus,
      DiZhi.WU: EnumStars.Mercury,
      DiZhi.WEI: EnumStars.Sun,
      DiZhi.SHEN: EnumStars.Moon,
      DiZhi.YOU: EnumStars.Mercury,
      DiZhi.XU: EnumStars.Venus,
      DiZhi.HAI: EnumStars.Mars,
    };

    return mapper[yearZhi]! == star ? EnumHuaYaoShenSha.XueZhi : null;
  }

  // 血忌
  static EnumHuaYaoShenSha? isXueJi(DiZhi yearZhi, EnumStars star) {
    Map<DiZhi, EnumStars> mapper = {
      DiZhi.ZI: EnumStars.Sun,
      DiZhi.CHOU: EnumStars.Saturn,
      DiZhi.YIN: EnumStars.Saturn,
      DiZhi.MAO: EnumStars.Sun,
      DiZhi.CHEN: EnumStars.Jupiter,
      DiZhi.SI: EnumStars.Mercury,
      DiZhi.WU: EnumStars.Mars,
      DiZhi.WEI: EnumStars.Venus,
      DiZhi.SHEN: EnumStars.Venus,
      DiZhi.YOU: EnumStars.Mars,
      DiZhi.XU: EnumStars.Mercury,
      DiZhi.HAI: EnumStars.Jupiter,
    };

    return mapper[yearZhi]! == star ? EnumHuaYaoShenSha.XueJi : null;
  }

  // 产星
  static EnumHuaYaoShenSha? isChanXing(DiZhi yearZhi, EnumStars star) {
    Map<DiZhi, EnumStars> mapper = {
      DiZhi.ZI: EnumStars.Venus,
      DiZhi.CHOU: EnumStars.Mercury,
      DiZhi.YIN: EnumStars.Jupiter,
      DiZhi.MAO: EnumStars.Mars,
      DiZhi.CHEN: EnumStars.Venus,
      DiZhi.SI: EnumStars.Mercury,
      DiZhi.WU: EnumStars.Jupiter,
      DiZhi.WEI: EnumStars.Mars,
      DiZhi.SHEN: EnumStars.Venus,
      DiZhi.YOU: EnumStars.Mercury,
      DiZhi.XU: EnumStars.Jupiter,
      DiZhi.HAI: EnumStars.Mars,
    };

    return mapper[yearZhi]! == star ? EnumHuaYaoShenSha.ChanXing : null;
  }

  // 值难
  static EnumHuaYaoShenSha? isZhiNan(JiaZi monthJiaZi, EnumStars star) {
    DiZhi monthDiZhi = monthJiaZi.diZhi;
    Map<DiZhi, Set<EnumStars>> mapper = {
      DiZhi.YIN: {EnumStars.Sun},
      DiZhi.MAO: {EnumStars.Sun},
      DiZhi.CHEN: {EnumStars.Moon},
      DiZhi.SI: {EnumStars.Moon},
      DiZhi.WU: {EnumStars.Mars, EnumStars.Luo},
      DiZhi.WEI: {EnumStars.Mars, EnumStars.Luo},
      DiZhi.SHEN: {EnumStars.Mercury, EnumStars.Bei},
      DiZhi.YOU: {EnumStars.Mercury, EnumStars.Bei},
      DiZhi.XU: {EnumStars.Jupiter, EnumStars.Qi},
      DiZhi.HAI: {EnumStars.Jupiter, EnumStars.Qi},
      DiZhi.ZI: {EnumStars.Venus},
      DiZhi.CHOU: {EnumStars.Venus},
    };

    return mapper[monthDiZhi]!.contains(star) ? EnumHuaYaoShenSha.ZhiNan : null;
  }

  // 寿元
  EnumHuaYaoShenSha? isShouYuan(JiaZi yearJiaZi, EnumStars star) {
    if ([EnumStars.Moon, EnumStars.Sun].contains(star)) {
      return null;
    }
    switch (yearJiaZi.naYin.fiveXing) {
      case FiveXing.JIN:
        return star == EnumStars.Venus ? EnumHuaYaoShenSha.ShouYuan : null;
      case FiveXing.MU:
        return star == EnumStars.Jupiter ? EnumHuaYaoShenSha.ShouYuan : null;
      case FiveXing.SHUI:
        return star == EnumStars.Mercury ? EnumHuaYaoShenSha.ShouYuan : null;
      case FiveXing.HUO:
        return star == EnumStars.Mars ? EnumHuaYaoShenSha.ShouYuan : null;
      case FiveXing.TU:
        return star == EnumStars.Saturn ? EnumHuaYaoShenSha.ShouYuan : null;
    }
  }

  static Map<EnumStars, Set<EnumHuaYaoShenSha>> getAllStarHuaYao(
      JiaZi yearJiaZi, JiaZi monthJiaZi) {
    Map<EnumStars, Set<EnumHuaYaoShenSha>> result = {
      EnumStars.Sun: {},
      EnumStars.Moon: {},
      EnumStars.Jupiter: {},
      EnumStars.Mars: {},
      EnumStars.Mercury: {},
      EnumStars.Venus: {},
      EnumStars.Saturn: {},
      EnumStars.Luo: {},
      EnumStars.Ji: {},
      EnumStars.Qi: {},
      EnumStars.Bei: {}
    };

    // 0. 先检查“寿元”
    // 0.1. 寿元是生年年干支的纳音五行对应的星体
    FiveXing yearNaYinFiveXing = yearJiaZi.naYin.fiveXing;
    final EnumStars shouYuanStar =
        EnumStars.fiveStars.firstWhere((e) => e.fiveXing == yearNaYinFiveXing);
    result[shouYuanStar]!.add(EnumHuaYaoShenSha.ShouYuan);

    // 1. 首先检查“值难”，只有值难一个化曜是基于月支进行的。
    for (var star in EnumStars.allStars) {
      if (EnumHuaYaoShenSha.isZhiNan(monthJiaZi, star) != null) {
        result[star]!.add(EnumHuaYaoShenSha.ZhiNan);
        // 结束forEach
        continue;
      }
    }

    // 2. 进行其他地支化曜的检测
    for (var star in EnumStars.allStars) {
      Set<EnumHuaYaoShenSha> res = starIsYearZhiShenSha(yearJiaZi.diZhi, star);
      result[star]!.addAll(res);
    }

    // 3. 进行年干化曜检查
    for (var star in EnumStars.allStars) {
      Set<EnumHuaYaoShenSha> res =
          starIsYearGanShenSha(yearJiaZi.tianGan, star);
      result[star]!.addAll(res);
    }
    return result;
  }
}

// 驾前论宫煞，顺
enum EnumBeforeTaiSuiShenSha {
  JianFeng(0, "剑锋", JiXiongEnum.XIONG),
  FuShi(0, "伏尸", JiXiongEnum.XIONG),
  SuiJia(0, "岁驾", JiXiongEnum.JI),

  TianKong(1, "天空", JiXiongEnum.PING),
  TaiYang(1, "太阳", JiXiongEnum.PING),

  DiCi(2, "地雌", JiXiongEnum.XIONG),
  SangMen(2, "丧门", JiXiongEnum.XIONG),
  DiSang(2, "地丧", JiXiongEnum.XIONG),

  TaiYin(3, "太阴", JiXiongEnum.PING),
  GouShen(3, "勾神", JiXiongEnum.XIONG),
  GuanSuo(3, "贯索", JiXiongEnum.XIONG),

  GuanFu(4, "官符", JiXiongEnum.XIONG),
  FeiFu(4, "飞符", JiXiongEnum.XIONG),
  NianFu(4, "年符", JiXiongEnum.XIONG),
  WuGui(4, "五鬼", JiXiongEnum.XIONG),

  WuShen(5, "月德", JiXiongEnum.JI),
  SiFu(5, "死符", JiXiongEnum.XIONG),
  XiaoHao(5, "小耗", JiXiongEnum.XIONG),

  DaHao(6, "大耗", JiXiongEnum.XIONG),
  SuiPo(6, "岁破", JiXiongEnum.XIONG),
  LanGan(6, "阑干", JiXiongEnum.XIONG),

  LongDe(7, "龙德", JiXiongEnum.JI),
  ZiWei(7, "紫薇", JiXiongEnum.JI),
  BaoBai(7, "暴败", JiXiongEnum.XIONG),
  TianE(7, "天厄", JiXiongEnum.XIONG),

  TianXiong(8, "天雄", JiXiongEnum.XIONG),
  BaiHu(8, "白虎", JiXiongEnum.XIONG),

  TianDe(9, "天德", JiXiongEnum.JI),
  JuanShe(9, "卷舌", JiXiongEnum.XIONG),
  JiaoSha(9, "绞杀", JiXiongEnum.XIONG),

  TianGou(10, "天狗", JiXiongEnum.XIONG),
  DiaoKe(10, "吊客", JiXiongEnum.XIONG),

  BingFu(11, "病符", JiXiongEnum.XIONG),
  MoYue(11, "蓦越", JiXiongEnum.XIONG);

  final int order;
  final String name;
  final JiXiongEnum jiXiong;
  const EnumBeforeTaiSuiShenSha(this.order, this.name, this.jiXiong);

  List<EnumBeforeTaiSuiShenSha> getByOrder(int order) {
    return EnumBeforeTaiSuiShenSha.values
        .where((e) => e.order == order)
        .toList();
  }

  static Map<EnumTwelveGong, List<EnumBeforeTaiSuiShenSha>> getByTiaSui(
      EnumTwelveGong taiSui) {
    Map<EnumTwelveGong, List<EnumBeforeTaiSuiShenSha>> result = {};
    final taiSuiAt = taiSui.zhi.index;
    EnumBeforeTaiSuiShenSha.values.forEach((e) {
      int index = (e.order + taiSuiAt) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      if (!result.containsKey(gong)) {
        result[gong] = [];
      }
      result[gong]!.add(e);
    });
    return result;
  }
}

enum EnumAfterTaiSuiShenSha {
  HongLuan(0, "红鸾", JiXiongEnum.JI),
  TianXi(6, "天喜", JiXiongEnum.JI),
  XueRen(7, "血刃", JiXiongEnum.XIONG),
  FuChen(7, "浮沉", JiXiongEnum.XIONG),
  JieShen(7, "解神", JiXiongEnum.JI),
  TianKu(3, "天哭", JiXiongEnum.XIONG),
  PiTou(1, "披头", JiXiongEnum.XIONG);

  // 索引数字，相较于红鸾所在的宫位，如太岁在子宫(1)，那么红鸾的宫位为4(1+3)卯
  final int offsetWitHongLuan;
  const EnumAfterTaiSuiShenSha(
      this.offsetWitHongLuan, String name, JiXiongEnum jiXiong);

  static Map<EnumTwelveGong, List<EnumAfterTaiSuiShenSha>> getByTiaSui(
      EnumTwelveGong taiSui) {
    Map<EnumTwelveGong, List<EnumAfterTaiSuiShenSha>> result = {};
    final taiSuiAt = taiSui.zhi.index;
    // 红鸾
    int hongLuanAtDiZhiOrder =
        EnumAfterTaiSuiShenSha.getHongLuanPositionByDiZhiOrder(taiSuiAt);
    DiZhi hongLuanAtDiZhi = DiZhi.getByOrder(hongLuanAtDiZhiOrder + 1);
    // 天喜
    int tianXiAtDiZhiOrder =
        (hongLuanAtDiZhiOrder + TianXi.offsetWitHongLuan) % 12;
    DiZhi tianXiAtDiZhi = DiZhi.getByOrder(tianXiAtDiZhiOrder + 1);
    // 血刃
    int xueRenAtDiZhiOrder =
        (hongLuanAtDiZhiOrder + XueRen.offsetWitHongLuan) % 12;
    DiZhi xueRenAtDiZhi = DiZhi.getByOrder(xueRenAtDiZhiOrder + 1);
    // 浮沉
    DiZhi fuChenAtDiZhi = DiZhi.getByOrder(xueRenAtDiZhiOrder + 1);
    // 解神
    DiZhi jieShenAtDiZhi = DiZhi.getByOrder(xueRenAtDiZhiOrder + 1);
    // 天哭
    int tianKuAtDiZhiOrder =
        (hongLuanAtDiZhiOrder + TianKu.offsetWitHongLuan) % 12;
    DiZhi tianKuAtDiZhi = DiZhi.getByOrder(tianKuAtDiZhiOrder + 1);
    // 披头
    int piTouAtDiZhiOrder =
        (hongLuanAtDiZhiOrder + PiTou.offsetWitHongLuan) % 12;
    DiZhi piTouAtDiZhi = DiZhi.getByOrder(piTouAtDiZhiOrder + 1);

    return {
      EnumTwelveGong.getEnumTwelveGongByZhi(hongLuanAtDiZhi): [
        EnumAfterTaiSuiShenSha.HongLuan
      ],
      EnumTwelveGong.getEnumTwelveGongByZhi(tianXiAtDiZhi): [
        EnumAfterTaiSuiShenSha.TianXi
      ],
      EnumTwelveGong.getEnumTwelveGongByZhi(xueRenAtDiZhi): [
        EnumAfterTaiSuiShenSha.XueRen,
        EnumAfterTaiSuiShenSha.FuChen,
        EnumAfterTaiSuiShenSha.JieShen
      ],
      EnumTwelveGong.getEnumTwelveGongByZhi(tianKuAtDiZhi): [
        EnumAfterTaiSuiShenSha.TianKu
      ],
      EnumTwelveGong.getEnumTwelveGongByZhi(piTouAtDiZhi): [
        EnumAfterTaiSuiShenSha.PiTou
      ],
    };
  }

  static int getHongLuanPositionByDiZhiOrder(int taiShui) {
    final Map<int, int> hongLuanMap = {
      0: 3, // 子 → 卯
      1: 2, // 丑 → 寅
      2: 1, // 寅 → 丑
      3: 0, // 卯 → 子
      4: 11, // 辰 → 亥
      5: 10, // 巳 → 戌
      6: 9, // 午 → 酉
      7: 8, // 未 → 申
      8: 7, // 申 → 未
      9: 6, // 酉 → 午
      10: 5, // 戌 → 巳
      11: 4 // 亥 → 辰
    };
    return hongLuanMap[taiShui] ?? 0;
  }
}

enum EnumShenShaBeforeHouseStar {
  YiMa("驿马", 0),
  // 马前第一位神煞，也叫“六害”，穿珠指掌云：一名“弱杀”。
  // 当与七政四余中的“六害（年干地支的地址六害对位）”，为避免混淆所以为“六厄”
  LiuE("六厄", 1),
  HuaGai("华盖", 2),
  JieSha("劫杀", 3),
  ZaiSha("灾杀", 4),
  TianSha("天杀", 5),
  DiSha("地杀", 6),
  NianSha("年杀", 7),
  YueSha("月杀", 8),
  WangShen("亡神", 9),
  JiangXing("将星", 10),
  PanAn("攀鞍", 11);

  final String name;
  final int offsetToYiMa;
  const EnumShenShaBeforeHouseStar(this.name, this.offsetToYiMa);

  // 传入驿马的位置，返回该位置的神煞
  // 以年支起驿马取
// 驿六华劫灾天地年月亡将扳
// 马害盖杀杀杀杀杀杀神星鞍
// 申子辰：寅卯辰巳午未申酉戌亥子丑。
// 寅午戌：申酉戌亥子丑寅卯辰巳午未。
// 巳酉丑：亥子丑寅卯辰巳午未申酉戌。
// 亥卯未：巳午未申酉戌亥子丑寅卯辰。
// 申子辰人马居寅，寅午戌人马居申，巳酉丑人马在亥，亥卯未人马在巳

// 未采用此种顺序。
// 附：《五行精纪》十二宫驿马例
// 驿马 六厄（穿珠指掌云：一名弱杀） 华盖 劫杀 灾杀 天杀 岁杀
// 地杀 亡神 将星 攀鞍（三命篡局）
// 驿马喻人乘马而致远也，长生临宫马主贵，病绝马主祸。
// 六厄至凶之神，克临则为灾重，不然亦小灾。

  static Map<EnumTwelveGong, EnumShenShaBeforeHouseStar> getByHousePosition(
      EnumTwelveGong yiMaGong) {
    Map<EnumTwelveGong, EnumShenShaBeforeHouseStar> result = {};
    EnumShenShaBeforeHouseStar.values.forEach((e) {
      int index = (e.offsetToYiMa + yiMaGong.index) % 12;
      EnumTwelveGong gong =
          EnumTwelveGong.getEnumTwelveGongByZhi(DiZhi.getByOrder(index + 1));
      result[gong] = e;
    });
    return result;
  }
}
