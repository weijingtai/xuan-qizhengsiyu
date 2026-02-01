import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

class GeJuModel {
  String name;
  String className;
  String books; // 灵台阁、十三补遗、通元赋
  String description;

  JiXiongEnum jiXiong;
  GeJuType geJuType;

  GeJuModel({
    required this.name,
    required this.className,
    required this.books,
    required this.description,
    required this.jiXiong,
    required this.geJuType,
  });
}

enum GeJuType {
  // 贫、贱、富、贵、夭、寿、贤、愚
  @JsonValue("贫")
  pin,
  @JsonValue("贱")
  jian,
  @JsonValue("富")
  fu,
  @JsonValue("贵")
  gui,
  @JsonValue("夭")
  yao,
  @JsonValue("寿")
  shou,
  @JsonValue("贤")
  xian,
  @JsonValue("愚")
  yu;
}
