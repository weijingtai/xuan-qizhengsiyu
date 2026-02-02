import 'package:common/enums/enum_28_constellations.dart';
import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 格局文本解析常量表
/// T-035: 关键字映射表
class GeJuTextConstants {
  // 星曜别名映射
  static final Map<String, EnumStars> starAliases = {
    // 七政
    "日": EnumStars.Sun, "太阳": EnumStars.Sun, "乌": EnumStars.Sun,
    "金乌": EnumStars.Sun, "君": EnumStars.Sun, "父": EnumStars.Sun,
    "月": EnumStars.Moon,
    "太阴": EnumStars.Moon,
    "兔": EnumStars.Moon,
    "玉兔": EnumStars.Moon,
    "蟾": EnumStars.Moon,
    "母": EnumStars.Moon,
    "夜明": EnumStars.Moon,
    "金": EnumStars.Venus, "太白": EnumStars.Venus, "长庚": EnumStars.Venus,
    "启明": EnumStars.Venus, "白虎": EnumStars.Venus,
    "木": EnumStars.Jupiter, "岁星": EnumStars.Jupiter, "岁": EnumStars.Jupiter,
    "青龙": EnumStars.Jupiter, "红杏": EnumStars.Jupiter, "寒梅": EnumStars.Jupiter,
    "水": EnumStars.Mercury, "辰星": EnumStars.Mercury, "玄武": EnumStars.Mercury,
    "火": EnumStars.Mars, "荧惑": EnumStars.Mars, "朱雀": EnumStars.Mars,
    "丹": EnumStars.Mars,
    "土": EnumStars.Saturn, "镇星": EnumStars.Saturn, "勾陈": EnumStars.Saturn,
    // 四余
    "气": EnumStars.Qi, "紫气": EnumStars.Qi, "景星": EnumStars.Qi,
    "祥云": EnumStars.Qi,
    "孛": EnumStars.Bei, "月孛": EnumStars.Bei, "太乙": EnumStars.Bei,
    "彗": EnumStars.Bei,
    "罗": EnumStars.Luo, "罗喉": EnumStars.Luo, "天首": EnumStars.Luo,
    "计": EnumStars.Ji, "计都": EnumStars.Ji, "天尾": EnumStars.Ji,
    "豹尾": EnumStars.Ji,
  };

  // 地支/宫位别名映射
  static final Map<String, EnumTwelveGong> gongAliases = {
    // 地支本名
    "子": EnumTwelveGong.Zi, "丑": EnumTwelveGong.Chou, "寅": EnumTwelveGong.Yin,
    "卯": EnumTwelveGong.Mao,
    "辰": EnumTwelveGong.Chen, "巳": EnumTwelveGong.Si, "午": EnumTwelveGong.Wu,
    "未": EnumTwelveGong.Wei,
    "申": EnumTwelveGong.Shen, "酉": EnumTwelveGong.You, "戌": EnumTwelveGong.Xu,
    "亥": EnumTwelveGong.Hai,
    // 十二次
    "寿星": EnumTwelveGong.Chen, "大火": EnumTwelveGong.Mao,
    "析木": EnumTwelveGong.Yin, "星纪": EnumTwelveGong.Chou,
    "玄枵": EnumTwelveGong.Zi, "娵訾": EnumTwelveGong.Hai, "降娄": EnumTwelveGong.Xu,
    "大梁": EnumTwelveGong.You,
    "实沈": EnumTwelveGong.Shen, "鹑首": EnumTwelveGong.Wei,
    "鹑火": EnumTwelveGong.Wu, "鹑尾": EnumTwelveGong.Si,
    // 分野/别称
    "齐": EnumTwelveGong.Zi, "宝瓶": EnumTwelveGong.Zi, "神后": EnumTwelveGong.Zi,
    "吴": EnumTwelveGong.Chou, "摩羯": EnumTwelveGong.Chou,
    "大吉": EnumTwelveGong.Chou,
    "燕": EnumTwelveGong.Yin, "人马": EnumTwelveGong.Yin, "功曹": EnumTwelveGong.Yin,
    "宋": EnumTwelveGong.Mao, "天蝎": EnumTwelveGong.Mao, "太冲": EnumTwelveGong.Mao,
    "郑": EnumTwelveGong.Chen, "天秤": EnumTwelveGong.Chen,
    "天罡": EnumTwelveGong.Chen,
    "楚": EnumTwelveGong.Si, "双女": EnumTwelveGong.Si, "太乙": EnumTwelveGong.Si,
    "周": EnumTwelveGong.Wu, "狮子": EnumTwelveGong.Wu, "胜光": EnumTwelveGong.Wu,
    "秦": EnumTwelveGong.Wei, "秦州": EnumTwelveGong.Wei, "巨蟹": EnumTwelveGong.Wei,
    "小吉": EnumTwelveGong.Wei, "鬼": EnumTwelveGong.Wei,
    "晋": EnumTwelveGong.Shen, "阴阳": EnumTwelveGong.Shen,
    "传送": EnumTwelveGong.Shen,
    "赵": EnumTwelveGong.You, "金牛": EnumTwelveGong.You, "从魁": EnumTwelveGong.You,
    "鲁": EnumTwelveGong.Xu, "白羊": EnumTwelveGong.Xu, "河魁": EnumTwelveGong.Xu,
    "卫": EnumTwelveGong.Hai, "双鱼": EnumTwelveGong.Hai, "登明": EnumTwelveGong.Hai,
  };

  // 28星宿名称 (Common 库中通常已有，这里做补充或从 Enum 获取)
  // 如果输入是 "毕度" "毕宿"，需要处理

  // 逻辑关键词
  static const List<String> conditionKeywords = [
    "同宫",
    "对照",
    "三合",
    "四正",
    "同躔",
    "同度",
    "夹",
    "拱",
    "会"
  ];

  // 否定词
  static const List<String> negativeKeywords = ["不", "非", "忌", "嫌", "无", "难"];

  /// 辅助查找方法
  static EnumStars? getStar(String name) {
    // 移除干扰字符
    name = name.replaceAll(RegExp(r"[星曜]"), "");
    return starAliases[name] ?? EnumStars.getBySingleName(name);
  }

  static EnumTwelveGong? getGong(String name) {
    // 移除干扰字符
    name = name.replaceAll(RegExp(r"[宫地]"), "");
    return gongAliases[name];
  }
}
