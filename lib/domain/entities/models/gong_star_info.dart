import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

part 'gong_star_info.g.dart';

enum StarGongPositionType {
  @JsonValue("同宫")
  tongGong("同宫", "指两颗或更多星体位于同一宫位内。同宫星体间的五行生克关系直接影响该宫位所主事项的吉凶"),
  @JsonValue("对宫")
  duiGong("对宫", "指宫位的地支相冲位置，即十二地支中的“六冲关系”（如子午冲、丑未冲"),
  @JsonValue("三方")
  sanFang("三方", "指某宫位的地支三合关系，即“三合局”（如申子辰水局、寅午戌火局）"),
  @JsonValue("四正")
  siZheng("四正", "与三方相似，但宫位为子午卯酉，辰戌丑未，寅申巳亥，往往好的不灵坏的灵"),
  @JsonValue("同络")
  tongLuo("同络", "星体在不同的宫位内，但入宫的度数相同（一般在0.5~1度内），叫做同络");

  final String name;
  final String description;
  const StarGongPositionType(this.name, this.description);
}

enum StarConstellationPositionType {
  @JsonValue("同经")
  tongJing("同经", "星体在同一个属性的星宿上会产生影响，叫做同经");

  final String name;
  final String description;
  const StarConstellationPositionType(this.name, this.description);
}

@JsonSerializable()
class GongStarInfo {
  /// T 为宫位 或 宿度
  StarGongPositionType positionType;
  Map<EnumTwelveGong, List<EnumStars>> mapper;
  GongStarInfo({required this.positionType, required this.mapper});
  factory GongStarInfo.fromJson(Map<String, dynamic> json) =>
      _$GongStarInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GongStarInfoToJson(this);
}

@JsonSerializable()
class ConstellationStarInfo {
  EnumStars constellationStar;
  // StarPositionType positionType;
  StarConstellationPositionType positionType;
  Map<Enum28Constellations, List<EnumStars>> mapper;

  ConstellationStarInfo(
      {required this.constellationStar,
      required this.mapper,
      required this.positionType});
  factory ConstellationStarInfo.fromJson(Map<String, dynamic> json) =>
      _$ConstellationStarInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ConstellationStarInfoToJson(this);
}

@JsonSerializable()
class SameLuoStarInfo {
  EnumStars star;
  List<EnumStars> sameLuoStars;
  SameLuoStarInfo({required this.star, required this.sameLuoStars});
  factory SameLuoStarInfo.fromJson(Map<String, dynamic> json) =>
      _$SameLuoStarInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SameLuoStarInfoToJson(this);
}
