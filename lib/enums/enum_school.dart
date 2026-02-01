import 'package:json_annotation/json_annotation.dart';

enum EnumSchoolType {
  @JsonValue("果老派")
  GuoLao("果老派"),
  @JsonValue("天官派")
  TianGuan("天官派"),
  @JsonValue("琴堂派")
  QinTang("琴堂派"),
  @JsonValue("自定义")
  Customerized("自定义");

  const EnumSchoolType(this.name);
  final String name;
}

enum EnumHuaYaoType {
  GuoLao("果老化曜"),
  TianGuan("天官化曜"),
  Both("同参"),
  None("不显示");

  final String name;
  const EnumHuaYaoType(this.name);
}
