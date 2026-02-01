import 'package:json_annotation/json_annotation.dart';

enum EnumStarGongPositionStatusType {
  // 庙、旺、喜、乐、怒、陷
  @JsonValue("庙")
  Miao("庙", true), // 入庙
  @JsonValue("旺")
  Wang("旺", true), // 乘旺
  @JsonValue("喜")
  Xi("喜", true), // 喜宫
  @JsonValue("乐")
  Le("乐", true), // 乐宫
  @JsonValue("怒")
  Nu("怒", true), // 怒宫
  @JsonValue("凶")
  Xian("凶", true), // 凶宫
  @JsonValue("正")
  Zheng("正", true), // 正垣
  @JsonValue("偏")
  Pian("偏", true), // 偏垣
  @JsonValue("垣")
  Yuan("垣", true), // 垣
  @JsonValue("殿")
  Dian("殿", false), // 升殿
  @JsonValue("凶")
  Xiong("凶", false),
  @JsonValue("贵")
  Gui("贵", false);

  final String name;
  final bool isGong; // 是否为宫位

  const EnumStarGongPositionStatusType(this.name, this.isGong);
}
