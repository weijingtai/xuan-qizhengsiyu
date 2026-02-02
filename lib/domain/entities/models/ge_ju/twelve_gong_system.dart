import 'package:common/enums/enum_di_zhi.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 十二次（赤道十二宮）系统
/// 对应中国传统赤道坐标系的十二次划分
enum TwelveCi {
  XuanXiao("玄枵", EnumTwelveGong.Zi),
  XingJi("星纪", EnumTwelveGong.Chou),
  XiMu("析木", EnumTwelveGong.Yin),
  DaHuo("大火", EnumTwelveGong.Mao),
  ShouXing("寿星", EnumTwelveGong.Chen),
  ChunWei("鹑尾", EnumTwelveGong.Si),
  ChunHuo("鹑火", EnumTwelveGong.Wu),
  ChunShou("鹑首", EnumTwelveGong.Wei),
  ShiShen("实沈", EnumTwelveGong.Shen),
  DaLiang("大梁", EnumTwelveGong.You),
  JiangLou("降娄", EnumTwelveGong.Xu),
  JuZi("娵訾", EnumTwelveGong.Hai);

  final String name;
  final EnumTwelveGong gong;
  const TwelveCi(this.name, this.gong);

  static TwelveCi? fromName(String name) {
    for (var val in values) {
      if (val.name == name) return val;
    }
    return null;
  }
}

/// 黄道十二宫系统（别名映射）
/// 对应西方黄道坐标系，但常用于七政四余古籍中指代地支对应的方位
enum TwelveZodiacAlias {
  BaoPing("宝瓶", EnumTwelveGong.Zi),
  MoJie("磨羯", EnumTwelveGong.Chou),
  RenMa("人马", EnumTwelveGong.Yin),
  TianXie("天蝎", EnumTwelveGong.Mao),
  TianCheng("天秤", EnumTwelveGong.Chen),
  ShuangNv("双女", EnumTwelveGong.Si),
  ShiZi("狮子", EnumTwelveGong.Wu),
  JuXie("巨蟹", EnumTwelveGong.Wei),
  ShuangZi("双子", EnumTwelveGong.Shen),
  JinNiu("金牛", EnumTwelveGong.You),
  BaiYang("白羊", EnumTwelveGong.Xu),
  ShuangYu("双鱼", EnumTwelveGong.Hai);

  final String name;
  final EnumTwelveGong gong;
  const TwelveZodiacAlias(this.name, this.gong);

  static TwelveZodiacAlias? fromName(String name) {
    for (var val in values) {
      if (val.name == name) return val;
    }
    return null;
  }
}

/// 统一的宫位名称解析工具
/// 支持地支、十二次、黄道别名解析为 EnumTwelveGong
class TwelveGongSystem {
  static EnumTwelveGong? resolve(String name) {
    // 1. 尝试地支解析
    final diZhi = DiZhi.getFromValue(name);
    if (diZhi != null) {
      return EnumTwelveGong.getEnumTwelveGongByZhi(diZhi);
    }

    // 2. 尝试十二次解析
    final ci = TwelveCi.fromName(name);
    if (ci != null) return ci.gong;

    // 3. 尝试黄道别名解析
    final zodiac = TwelveZodiacAlias.fromName(name);
    if (zodiac != null) return zodiac.gong;

    // 4. 尝试繁体兼容（部分古籍可能用繁体）
    // 简单映射，根据 ge_ju_1.txt 出现的词汇补充
    switch (name) {
      case "寶瓶":
        return EnumTwelveGong.Zi;
      case "雙魚":
        return EnumTwelveGong.Hai;
      case "雙女":
        return EnumTwelveGong.Si;
      case "獅子":
        return EnumTwelveGong.Wu;
      case "巨蟹":
        return EnumTwelveGong.Wei;
      case "天蠍":
        return EnumTwelveGong.Mao; // 繁体蝎
      case "雙子":
        return EnumTwelveGong.Shen;
      // ... 其他可能有繁体的词
    }

    // 5. 尝试直接匹配 EnumTwelveGong (支持 English Key, e.g. "Zi")
    try {
      return EnumTwelveGong.values.firstWhere(
        (e) =>
            e.name == name ||
            e.toString().split('.').last.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {}

    return null;
  }
}
