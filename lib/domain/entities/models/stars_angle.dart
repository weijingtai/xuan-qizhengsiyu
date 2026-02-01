import 'dart:convert';

import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';

part 'stars_angle.g.dart';

class StarWalkingInfo {
  EnumStars star;
  FiveStarWalkingType walkingType;
  double speed;
  double angle;
  DateTime walkingTypeStartAt;
  StarWalkingInfo({
    required this.star,
    required this.walkingType,
    required this.walkingTypeStartAt,
    required this.speed,
    required this.angle,
  });

  // toJson
  Map<String, dynamic> toJson() => {
        "star": star.name,
        "walkingType": walkingType.name,
        "walkingTypeStartAt": walkingTypeStartAt.toString(),
        "speed": speed,
        "angle": angle,
      };
  // toString print json
  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class BaseFiveStarWalkingInfo {
  final EnumStars star;
  final double speed;
  FiveStarWalkingType walkingType;
  final StarWalkingTypeThreshold threshold;

  BaseFiveStarWalkingInfo({
    required this.star,
    required this.speed,
    required this.walkingType,
    required this.threshold,
  });
  factory BaseFiveStarWalkingInfo.fromJson(Map<String, dynamic> json) =>
      _$BaseFiveStarWalkingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BaseFiveStarWalkingInfoToJson(this);
}

class FiveStarWalkingInfo {
  EnumStars star;
  double angle;
  FiveStarWalkingType walkingType;
  DateTime walkingTypeStartAt;
  DateTime walkingTypeEndAt;

  String speedThresholdName; // 阈值使用的参数  当前多为moira
  double maxSpeed;
  double retrogradeMaxSpeed;

  double staySpeedThresholdAt; // 留行开始阈值
  double reversedSpeedThresholdAt; // 逆行开始阈值

  double? fastSpeedThresholdAt; // 疾行开始阈值
  double? lowSpeedThresholdAt; // 迟行开始阈值

  bool isHidden; // 伏
  DateTime? hiddenStartAt;
  DateTime? hiddenEndAt;

  List<StarWalkingInfo> nextSeq;
  List<StarWalkingInfo> prevSeq;
  FiveStarWalkingInfo({
    required this.star,
    required this.angle,
    required this.walkingType,
    required this.walkingTypeStartAt,
    required this.walkingTypeEndAt,
    required this.speedThresholdName,
    required this.maxSpeed,
    required this.retrogradeMaxSpeed,
    required this.staySpeedThresholdAt,
    required this.reversedSpeedThresholdAt,
    required this.nextSeq,
    required this.prevSeq,
    this.fastSpeedThresholdAt,
    this.lowSpeedThresholdAt,
    this.isHidden = false,
    this.hiddenStartAt,
    this.hiddenEndAt,
  });
}
