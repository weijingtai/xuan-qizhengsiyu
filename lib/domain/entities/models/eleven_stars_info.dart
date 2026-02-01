import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'package:qizhengsiyu/enums/enum_moon_phases.dart';

part 'eleven_stars_info.g.dart';

@JsonSerializable()
class ElevenStarsInfo {
  final EnumStars star;
  final double angle;
  final EnteredInfo enterInfo;
  final FiveStarWalkingType fiveStarWalkingType;
  final double walkingSpeed;
  // final bool isSlave;
  bool get isSlave => star.isYuNu;
  final EnumStarsPriority priority; // this field only be used for sort
  // bool isHidden; // 是否为伏
  EnumTwelveGong get enteredGong => enterInfo.gong;
  double get enteredGongDegree => enterInfo.atGongDegree;
  Enum28Constellations get enteredStarInn => enterInfo.inn;
  double get enteredStarInnDegree => enterInfo.atInnDegree;

  ElevenStarsInfo(
      {required this.star,
      required this.angle,
      required this.enterInfo,
      required this.fiveStarWalkingType,
      required this.walkingSpeed,
      required this.priority
      // required this.isHidden,
      });

  factory ElevenStarsInfo.fromJson(Map<String, dynamic> json) =>
      _$ElevenStarsInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ElevenStarsInfoToJson(this);
}

@JsonSerializable()
class FiveStarsInfo extends ElevenStarsInfo {
  FiveStarsInfo({
    required EnumStars star,
    required double angle,
    required EnteredInfo enterInfo,
    required FiveStarWalkingType fiveStarWalkingType,
    required double walkingSpeed,
    // required bool isHidden
  }) : super(
            star: star,
            angle: angle,
            enterInfo: enterInfo,
            fiveStarWalkingType: fiveStarWalkingType,
            walkingSpeed: walkingSpeed,
            priority: EnumStarsPriority.Normal
            // isHidden: isHidden,
            );

  factory FiveStarsInfo.fromJson(Map<String, dynamic> json) =>
      _$FiveStarsInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FiveStarsInfoToJson(this);
}

@JsonSerializable()
class SunInfo extends ElevenStarsInfo {
  SunInfo({
    required double angle,
    required EnteredInfo enterInfo,
  }) : super(
          star: EnumStars.Sun,
          angle: angle,
          enterInfo: enterInfo,
          fiveStarWalkingType: FiveStarWalkingType.Normal,
          walkingSpeed: 0.0, // 需要重写
          // isHidden: false,
          priority: EnumStarsPriority.Primary,
        );

  factory SunInfo.fromJson(Map<String, dynamic> json) =>
      _$SunInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SunInfoToJson(this);
}

@JsonSerializable()
class MoonInfo extends ElevenStarsInfo {
  EnumMoonPhases moonPhase;
  MoonInfo({
    required double angle,
    required EnteredInfo enterInfo,
    required this.moonPhase,
    // required bool isHidden
  }) : super(
          star: EnumStars.Moon,
          angle: angle,
          enterInfo: enterInfo,
          fiveStarWalkingType: FiveStarWalkingType.Normal,
          walkingSpeed: 0.0, // 需要重写
          // isHidden: isHidden,
          priority: EnumStarsPriority.Secondary,
        );

  factory MoonInfo.fromJson(Map<String, dynamic> json) =>
      _$MoonInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MoonInfoToJson(this);
}

@JsonSerializable()
class FourSlaveStarInfo extends ElevenStarsInfo {
  FourSlaveStarInfo({
    required EnumStars star,
    required double angle,
    required EnteredInfo enterInfo,
    required double walkingSpeed,
  }) : super(
          star: star,
          angle: angle,
          enterInfo: enterInfo,
          fiveStarWalkingType: FiveStarWalkingType.Normal,
          walkingSpeed: walkingSpeed,
          // isHidden: false,
          priority: EnumStarsPriority.Lowest,
        );
  FourSlaveStarInfo.qi({
    required double angle,
    required EnteredInfo enterInfo,
  }) : super(
          star: EnumStars.Qi,
          angle: angle,
          enterInfo: enterInfo,
          fiveStarWalkingType: FiveStarWalkingType.Normal,
          walkingSpeed: 0.0352,
          // isHidden: false,
          priority: EnumStarsPriority.Normal,
        );
  FourSlaveStarInfo.bei({
    required double angle,
    required EnteredInfo enterInfo,
  }) : super(
          star: EnumStars.Bei,
          angle: angle,
          enterInfo: enterInfo,
          fiveStarWalkingType: FiveStarWalkingType.Normal,
          walkingSpeed: 0.11,
          // isHidden: false,
          priority: EnumStarsPriority.Normal,
        );

  factory FourSlaveStarInfo.fromJson(Map<String, dynamic> json) =>
      _$FourSlaveStarInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FourSlaveStarInfoToJson(this);
}

@JsonSerializable()
class LouJiStarsInfo extends FourSlaveStarInfo {
  bool get isLuo => star == EnumStars.Luo;
  bool get isJi => star == EnumStars.Ji;
  LouJiStarsInfo({
    required EnumStars star,
    required double angle,
    required EnteredInfo enterInfo,
  }) : super(
          star: star,
          angle: angle,
          enterInfo: enterInfo,
          walkingSpeed: 0.0055,
        );

  factory LouJiStarsInfo.fromJson(Map<String, dynamic> json) =>
      _$LouJiStarsInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$LouJiStarsInfoToJson(this);
}
