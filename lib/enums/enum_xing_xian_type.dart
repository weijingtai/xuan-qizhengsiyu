import 'package:json_annotation/json_annotation.dart';

enum EnumXingXianType {
  @JsonValue("daXian")
  daXian("洞微大限"),

  @JsonValue("xian106")
  xian106("洞微百六"),

  @JsonValue("feiXian")
  feiXian("洞微飞限"),

  @JsonValue("yang9")
  yang9("洞微阳九");

  final String value;
  const EnumXingXianType(this.value);

  @override
  String toString() => value;
}
