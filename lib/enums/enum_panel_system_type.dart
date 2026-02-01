import 'package:json_annotation/json_annotation.dart';

///
/// 天文坐标基准体系
enum CelestialCoordinateSystem {
  @JsonValue("黄道制")
  ecliptic(
    "黄道制",
    "以黄道面为基准划分十二宫，接近西方占星学体系",
  ),
  @JsonValue("赤道制")
  equatorial(
    "赤道制",
    "以赤道面为基准划分十二宫，符合中国传统阴阳五行理论",
  ),
  @JsonValue("天赤道制")
  skyEquatorial(
    "天赤道制",
    "以天赤道面为基准划分十二宫，周天365.25°合一年之数，太阳日行一度，符合中国传统阴阳五行理论",
  ),
  @JsonValue("似黄道恒星制")
  pseudoEcliptic(
    "似黄道恒星制",
    "采用不等宫系统，通过赤道坐标投影推算黄道位置",
  );

  final String name;
  final String description;

  const CelestialCoordinateSystem(
    this.name,
    this.description,
  );
}

/// 星宿体系类型
enum ConstellationSystemType {
  @JsonValue("古宿制")
  classical("古宿制", "沿用中国古代划分的二十八星宿固定位置，未根据岁差调整，当使用恒星制时，为恒星不变"),
  @JsonValue("矫正古宿制")
  adjustedClassical(
    "矫正古宿制",
    "在古宿制基础上校正岁差对齐当前星轨",
  ),
  @JsonValue("今宿制")
  modern("今宿制", "基于现代天文数据动态调整星宿位置");

  final String name;
  final String description;

  const ConstellationSystemType(this.name, this.description);
}

/// 宫位划分体系
enum HouseDivisionSystem {
  @JsonValue("等宫制")
  equal("等宫制", "十二宫平均分360°"),
  @JsonValue("赤道等宫制")
  equatorialEqual("赤道等宫制", "十二宫均分365.25°"),
  @JsonValue("不等宫制")
  unequal("不等宫制", "采用实际天赤道投影划分"),
  @JsonValue("四正")
  equatorialFourZheng(
      "四正", "子午卯酉四正宫为31.312°，其余十宫各为30° `31.312*4+30*8=365.25`周天之数, 使用时四舍五入"),
  @JsonValue("日月")
  equatorialSunMoon(
      "日月", "午未宫为32.625°，其余十宫各为30° `32.625*2+30*10=365.25`周天之数, 使用时四舍五入"),
  equatorialZiWu(
      "子午", "子午宫为32.625°，其余十宫各为30° `32.625*2+30*10=365.25`周天之数, 使用时四舍五入");

  final String name;
  final String description;

  const HouseDivisionSystem(this.name, this.description);
}

enum PanelSystemType {
  @JsonValue("回归制")
  tropical("回归制"),
  @JsonValue("恒星制")
  sidereal("恒星制");

  final String name;
  const PanelSystemType(this.name);
}
