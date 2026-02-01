import 'package:json_annotation/json_annotation.dart';

enum EnumSettleLifeType {
  @JsonValue("byMao")
  Mao("Mao", "七政四余最基础的定命方式，生时顺数至卯", "果老星宗"),
  @JsonValue("byYinMaoChen")
  YinMaoChen("YinMaoChen", "根据真太阳时下太阳出生时间的不同进行「寅卯辰」三宫作为命宫的选择", "真太阳时"),
  @JsonValue("byMannual")
  Mannual("mannual", "手动指定，手动调整命宫", "自定义"),
  @JsonValue("byAscendant")
  Ascendant("ascendant", "上升点", "西占");

  final String name;
  final String description;
  final String source;
  const EnumSettleLifeType(this.name, this.description, this.source);
}

enum EnumSettleBodyType {
  @JsonValue("byTaiYin")
  moon("taiYin", "太阴落宫即是身宫", "果老星宗"),
  @JsonValue("byYou")
  you("you", "太阴落宫逆数制酉时为身宫", "郑氏星案");

  // TODO: 并不是主流，所以暂时不支持
  // @JsonValue("moonRise")
  // moonRaise("moonRise", "月亮落宫逆数制月亮升起", "未知");

  final String name;
  final String description;
  final String source;
  const EnumSettleBodyType(this.name, this.description, this.source);
}
