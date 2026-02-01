import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'naming_degree_pair.dart';

part 'body_life_model.g.dart';

@JsonSerializable()
class BodyLifeModel {
  // 身命
  // final DiZhi sunEnteredGong;
  // final double sunEnteredGongDegree;

  final GongDegree lifeGongInfo;
  final ConstellationDegree lifeConstellationInfo;
  final GongDegree bodyGongInfo;
  final ConstellationDegree bodyConstellationInfo;

  /// 命宫
  // final EnumSettleLifeType settleLife;
  EnumTwelveGong get lifeGong => lifeGongInfo.gong;
  double get lifeDegree => lifeGongInfo.degree;

  /// 命度
  Enum28Constellations get lifeConstellatioin =>
      lifeConstellationInfo.constellation;
  double get lifeConstellationDegree => lifeConstellationInfo.degree;

  /// 身宫
  ///
  // final EnumSettleBodyType settleBody;
  EnumTwelveGong get bodyGong => bodyGongInfo.gong;
  double get bodyGongDegree => bodyGongInfo.degree;

  Enum28Constellations get bodyConstellation =>
      bodyConstellationInfo.constellation;
  double get bodyConstellationDegree => bodyConstellationInfo.degree;

  BodyLifeModel({
    required this.lifeGongInfo,
    required this.lifeConstellationInfo,
    required this.bodyGongInfo,
    required this.bodyConstellationInfo,
  });

  factory BodyLifeModel.fromJson(Map<String, dynamic> json) =>
      _$BodyLifeModelFromJson(json);
  Map<String, dynamic> toJson() => _$BodyLifeModelToJson(this);
}
