import 'package:json_annotation/json_annotation.dart';

enum FourSeasonRelationshipType {
  @JsonValue("喜")
  Xi("喜"),
  @JsonValue("忌")
  Ji("忌"),
  @JsonValue("调候")
  TiaoHou("调候"),
  // @JsonValue("护主")
  // hu("护"),
  // @JsonValue("犯主")
  // fan("犯"),
  @JsonValue("无")
  Unknown("无");

  final String name;
  const FourSeasonRelationshipType(this.name);
}
