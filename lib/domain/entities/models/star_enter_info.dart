import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'naming_degree_pair.dart';

part 'star_enter_info.g.dart';

@JsonSerializable()
class EnteredInfo {
  StarDegree originalStar;
  GongDegree enterGongInfo;
  ConstellationDegree enterInnInfo;

  EnumStars get star => originalStar.star;
  double get atDegree => originalStar.degree;
  EnumTwelveGong get gong => enterGongInfo.gong;
  double get atGongDegree => enterGongInfo.degree;
  Enum28Constellations get inn => enterInnInfo.constellation;
  double get atInnDegree => enterInnInfo.degree;

  EnteredInfo({
    required this.originalStar,
    required this.enterGongInfo,
    required this.enterInnInfo,
  });

  factory EnteredInfo.fromJson(Map<String, dynamic> json) =>
      _$EnteredInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EnteredInfoToJson(this);
}
