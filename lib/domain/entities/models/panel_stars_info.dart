import 'dart:convert';

import 'package:common/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

import 'eleven_stars_info.dart';
import 'star_angle_speed.dart';

class PanelStarsInfo {
  final ElevenStarsInfo sun;
  final MoonInfo moon;

  final FiveStarsInfo venus;
  final FiveStarsInfo jupiter;
  final FiveStarsInfo mars;
  final FiveStarsInfo saturn;
  final FiveStarsInfo water;

  final LouJiStarsInfo ji;
  final LouJiStarsInfo luo;
  final ElevenStarsInfo bei;
  final ElevenStarsInfo qi;
  final bool isSunLunarTouch; // 是否为日月合
  final bool isLunarEclipse;
  final bool isSunEclipse;

  PanelStarsInfo({
    required this.sun,
    required this.moon,
    required this.venus,
    required this.jupiter,
    required this.mars,
    required this.saturn,
    required this.water,
    required this.ji,
    required this.luo,
    required this.bei,
    required this.qi,
    required this.isSunLunarTouch,
    required this.isLunarEclipse,
    required this.isSunEclipse,
  });

  ElevenStarsInfo getByStar(EnumStars star) {
    switch (star) {
      case EnumStars.Moon:
        return moon;
      case EnumStars.Sun:
        return sun;
      case EnumStars.Venus:
        return venus;
      case EnumStars.Mercury:
        return water;
      case EnumStars.Jupiter:
        return jupiter;
      case EnumStars.Mars:
        return mars;
      case EnumStars.Saturn:
        return saturn;
      case EnumStars.Qi:
        return qi;
      case EnumStars.Bei:
        return bei;
      case EnumStars.Ji:
        return ji;
      case EnumStars.Luo:
        return luo;
    }
  }
}

class StarsAngle {
  final double sun;
  final double moon;

  final double venus;
  final double venusSpeed;
  final double jupiter;
  final double jupiterSpeed;
  final double mars;
  final double marsSpeed;
  final double saturn;
  final double saturnSpeed;
  final double water;
  final double waterSpeed;

  final double southNode;
  final double northNode;
  final double lilith;
  final double qi;

  static StarsAngle fromMapper(Map<EnumStars, StarAngleSpeed> mapper) {
    return StarsAngle(
      sun: mapper[EnumStars.Sun]!.angle,
      moon: mapper[EnumStars.Moon]!.angle,
      venus: mapper[EnumStars.Venus]!.angle,
      venusSpeed: mapper[EnumStars.Venus]!.speed,
      jupiter: mapper[EnumStars.Jupiter]!.angle,
      jupiterSpeed: mapper[EnumStars.Jupiter]!.speed,
      mars: mapper[EnumStars.Mars]!.angle,
      marsSpeed: mapper[EnumStars.Mars]!.speed,
      saturn: mapper[EnumStars.Saturn]!.angle,
      saturnSpeed: mapper[EnumStars.Saturn]!.speed,
      water: mapper[EnumStars.Mercury]!.angle,
      waterSpeed: mapper[EnumStars.Mercury]!.speed,
      southNode: mapper[EnumStars.Luo]!.angle,
      northNode: mapper[EnumStars.Ji]!.angle,
      lilith: mapper[EnumStars.Bei]!.angle,
      qi: mapper[EnumStars.Qi]!.angle,
    );
  }

  StarsAngle({
    required this.sun,
    required this.moon,
    required this.venus,
    required this.venusSpeed,
    required this.jupiter,
    required this.jupiterSpeed,
    required this.mars,
    required this.marsSpeed,
    required this.saturn,
    required this.saturnSpeed,
    required this.water,
    required this.waterSpeed,
    required this.southNode,
    required this.northNode,
    required this.lilith,
    required this.qi,
  });

  Map<EnumStars, StarAngleSpeed> toMap() => {
        EnumStars.Sun: StarAngleSpeed(angle: sun, speed: 0),
        EnumStars.Moon: StarAngleSpeed(angle: moon, speed: 0),
        EnumStars.Venus: StarAngleSpeed(angle: venus, speed: venusSpeed),
        EnumStars.Jupiter: StarAngleSpeed(angle: jupiter, speed: jupiterSpeed),
        EnumStars.Mars: StarAngleSpeed(angle: mars, speed: marsSpeed),
        EnumStars.Saturn: StarAngleSpeed(angle: saturn, speed: saturnSpeed),
        EnumStars.Mercury: StarAngleSpeed(angle: water, speed: waterSpeed),
        EnumStars.Luo: StarAngleSpeed(angle: southNode, speed: 0),
        EnumStars.Ji: StarAngleSpeed(angle: northNode, speed: 0),
        EnumStars.Bei: StarAngleSpeed(angle: lilith, speed: 0),
        EnumStars.Qi: StarAngleSpeed(angle: qi, speed: 0),
      };

  double getByStar(EnumStars star) {
    double starAngle = 0;
    switch (star) {
      case EnumStars.Moon:
        starAngle = moon;
        break;
      case EnumStars.Sun:
        starAngle = sun;
        break;
      case EnumStars.Venus:
        starAngle = venus;
        break;
      case EnumStars.Mercury:
        starAngle = water;
        break;
      case EnumStars.Jupiter:
        starAngle = jupiter;
        break;
      case EnumStars.Mars:
        starAngle = mars;
        break;
      case EnumStars.Saturn:
        starAngle = saturn;
        break;
      case EnumStars.Qi:
        starAngle = qi;
        break;
      case EnumStars.Bei:
        starAngle = lilith;
        break;
      case EnumStars.Ji:
        starAngle = northNode;
        break;
      case EnumStars.Luo:
        starAngle = southNode;
        break;
    }
    return starAngle;
  }

  // to json
  Map<String, dynamic> toJson() => {
        'sun': sun,
        'lunar': moon,
        'Venus': venus,
        'Jupiter': jupiter,
        'Mars': mars,
        'Saturn': saturn,
        'water': water,
        'southNode': southNode,
        'northNode': northNode,
        'lilith': lilith,
        'qi': qi,
      };
  // toString print json
  @override
  String toString() => jsonEncode(toJson());

  // # moira 中
  // #   火星迟行 速度节点为“0.409” 大于时为正常速度，小于时为迟行
  // #   火星疾行 速度节点为“0.706” 大于时为疾行速度，小于时为正常
  // #   火星留行 速度节点为“0.074” 小于时开始成为“留行”
  // #  火星逆行节点 -0.077°
  // #   火星最快 0.778°/天  最慢 -0.386°/天
  //
  // #   金星疾行 没有疾行
  // #   金星迟行、常速 速度节点为“0.709” 大于时为正常速度，小于时为迟行
  // #   --金星留行 速度节点为“0.731” 小于时开始成为“留行”-- 有误
  // #   金星迟、留行节点 0.103°/天
  // #  金星逆行节点 -0.115°/天
  // #   金星最快 1.238°/天  最慢-0.613°/天
  //
  // #   木星迟行 速度节点为“0.048” 大于时为正常速度，小于时为迟行
  // #   木星疾行 0.23°/天 大于时为疾行速度，小于时为正常
  // #   木星留行 速度节点为“0.011” 小于时开始成为“留行”
  // # 木星逆行节点 -0.022°/天
  // #   木星最快  0.236°/天  最慢-0.134°/天
  //
  // # 水星 最快  2.2°/天   最慢 -1.348°/天【常】
  // #   水星迟行 速度节点为“0.868” 大于时为正常速度，小于时为迟行
  // #   水星疾行 速度节点"1.499",大于时为疾行速度，小于时为正常
  // #   水星留行 速度节点"0.129",大 小于时开始成为“留行”
  // # 水星逆行 -0.089°/天
  //
  // # 土星 最快  0.122°/天  最慢 -0.075°/天
  // #  土星没有迟与疾
  // #   土星留行 速度节点"0.019",大 小于时开始成为“留行”
  // #   土星逆行 节点-0.012°/天

  // tuple6.item1 最快速度，item2 逆行最快，item3 逆行，item4 留行，item5疾行，item6 迟行
  static Map<EnumStars,
          Tuple6<double, double, double, double, double?, double?>>
      moirasFiveStartsMapper = {
    EnumStars.Mars: const Tuple6(0.778, -0.386, -0.077, 0.074, 0.706, 0.409),
    EnumStars.Venus: const Tuple6(1.238, -0.613, -0.115, 0.103, null, 0.709),
    EnumStars.Jupiter: const Tuple6(0.236, -0.134, 0.022, 0.011, 0.23, 0.048),
    EnumStars.Mercury: const Tuple6(2.2, -1.348, -0.089, 0.129, 1.499, 0.868),
    EnumStars.Saturn: const Tuple6(0.122, -0.075, -0.012, 0.019, null, null),
  };
}

class UIStarsAngle {
  final double sun;
  final double uiSunAngle;

  final double moon;
  final double uiMoonAngle;

  final double Venus;
  final double VenusSpeed;
  final double uiVenusAngle;

  final double Jupiter;
  final double uiJupiterAngle;
  final double JupiterSpeed;

  final double Mars;
  final double uiMarsAngle;
  final double MarsSpeed;

  final double Saturn;
  final double uiSaturnAngle;
  final double SaturnSpeed;

  final double water;
  final double uiWaterAngle;
  final double waterSpeed;

  final double southNode;
  final double uiSouthNodeAngle;

  final double northNode;
  final double uiNorthNodeAngle;

  final double lilith;
  final double uiBeiAngle;

  final double qi;
  final double uiQiAngle;

  UIStarsAngle({
    required this.sun,
    required this.moon,
    required this.Venus,
    required this.VenusSpeed,
    required this.Jupiter,
    required this.JupiterSpeed,
    required this.Mars,
    required this.MarsSpeed,
    required this.Saturn,
    required this.SaturnSpeed,
    required this.water,
    required this.waterSpeed,
    required this.southNode,
    required this.northNode,
    required this.lilith,
    required this.qi,
    required this.uiSunAngle,
    required this.uiMoonAngle,
    required this.uiVenusAngle,
    required this.uiJupiterAngle,
    required this.uiMarsAngle,
    required this.uiSaturnAngle,
    required this.uiWaterAngle,
    required this.uiSouthNodeAngle,
    required this.uiNorthNodeAngle,
    required this.uiBeiAngle,
    required this.uiQiAngle,
  });

  UIStarsAngle.from(
    StarsAngle starsAngle, {
    required double? uiSunAngle,
    required double? uiMoonAngle,
    required double? uiVenusAngle,
    required double? uiJupiterAngle,
    required double? uiMarsAngle,
    required double? uiSaturnAngle,
    required double? uiWaterAngle,
    required double? uiSouthNodeAngle,
    required double? uiNorthNodeAngle,
    required double? uiBeiNodeAngle,
    required double? uiQiAngle,
  }) : this(
          sun: starsAngle.sun,
          moon: starsAngle.moon,
          Venus: starsAngle.venus,
          VenusSpeed: starsAngle.venusSpeed,
          Jupiter: starsAngle.jupiter,
          JupiterSpeed: starsAngle.jupiterSpeed,
          Mars: starsAngle.mars,
          MarsSpeed: starsAngle.marsSpeed,
          Saturn: starsAngle.saturn,
          SaturnSpeed: starsAngle.saturnSpeed,
          water: starsAngle.water,
          waterSpeed: starsAngle.waterSpeed,
          southNode: starsAngle.southNode,
          northNode: starsAngle.northNode,
          lilith: starsAngle.lilith,
          qi: starsAngle.qi,
          uiSunAngle: uiSunAngle ?? starsAngle.sun,
          uiMoonAngle: uiMoonAngle ?? starsAngle.moon,
          uiVenusAngle: uiVenusAngle ?? starsAngle.venus,
          uiJupiterAngle: uiJupiterAngle ?? starsAngle.jupiter,
          uiMarsAngle: uiMarsAngle ?? starsAngle.mars,
          uiSaturnAngle: uiSaturnAngle ?? starsAngle.saturn,
          uiWaterAngle: uiWaterAngle ?? starsAngle.water,
          uiSouthNodeAngle: uiSouthNodeAngle ?? starsAngle.southNode,
          uiNorthNodeAngle: uiNorthNodeAngle ?? starsAngle.northNode,
          uiBeiAngle: uiBeiNodeAngle ?? starsAngle.lilith,
          uiQiAngle: uiQiAngle ?? starsAngle.qi,
        );

  double getByStar(EnumStars star) {
    double starAngle = 0;
    switch (star) {
      case EnumStars.Moon:
        starAngle = moon;
        break;
      case EnumStars.Sun:
        starAngle = sun;
        break;
      case EnumStars.Venus:
        starAngle = Venus;
        break;
      case EnumStars.Mercury:
        starAngle = water;
        break;
      case EnumStars.Jupiter:
        starAngle = Jupiter;
        break;
      case EnumStars.Mars:
        starAngle = Mars;
        break;
      case EnumStars.Saturn:
        starAngle = Saturn;
        break;
      case EnumStars.Qi:
        starAngle = qi;
        break;
      case EnumStars.Bei:
        starAngle = lilith;
        break;
      case EnumStars.Ji:
        starAngle = northNode;
        break;
      case EnumStars.Luo:
        starAngle = southNode;
        break;
    }
    return starAngle;
  }

  double getUIAngleByStar(EnumStars star) {
    double starAngle = 0;
    switch (star) {
      case EnumStars.Moon:
        starAngle = uiMoonAngle;
        break;
      case EnumStars.Sun:
        starAngle = uiSunAngle;
        break;
      case EnumStars.Venus:
        starAngle = uiVenusAngle;
        break;
      case EnumStars.Mercury:
        starAngle = uiWaterAngle;
        break;
      case EnumStars.Jupiter:
        starAngle = uiJupiterAngle;
        break;
      case EnumStars.Mars:
        starAngle = uiMarsAngle;
        break;
      case EnumStars.Saturn:
        starAngle = uiSaturnAngle;
        break;
      case EnumStars.Qi:
        starAngle = uiQiAngle;
        break;
      case EnumStars.Bei:
        starAngle = uiBeiAngle;
        break;
      case EnumStars.Ji:
        starAngle = uiNorthNodeAngle;
        break;
      case EnumStars.Luo:
        starAngle = uiSaturnAngle;
        break;
    }
    return starAngle;
  }

  // to json
  Map<String, dynamic> toJson() => {
        'sun': sun,
        'lunar': moon,
        'Venus': Venus,
        'Jupiter': Jupiter,
        'Mars': Mars,
        'Saturn': Saturn,
        'water': water,
        'southNode': southNode,
        'northNode': northNode,
        'lilith': lilith,
        'qi': qi,
      };
  // toString print json
  @override
  String toString() => jsonEncode(toJson());

  // # moira 中
  // #   火星迟行 速度节点为“0.409” 大于时为正常速度，小于时为迟行
  // #   火星疾行 速度节点为“0.706” 大于时为疾行速度，小于时为正常
  // #   火星留行 速度节点为“0.074” 小于时开始成为“留行”
  // #  火星逆行节点 -0.077°
  // #   火星最快 0.778°/天  最慢 -0.386°/天
  //
  // #   金星疾行 没有疾行
  // #   金星迟行、常速 速度节点为“0.709” 大于时为正常速度，小于时为迟行
  // #   --金星留行 速度节点为“0.731” 小于时开始成为“留行”-- 有误
  // #   金星迟、留行节点 0.103°/天
  // #  金星逆行节点 -0.115°/天
  // #   金星最快 1.238°/天  最慢-0.613°/天
  //
  // #   木星迟行 速度节点为“0.048” 大于时为正常速度，小于时为迟行
  // #   木星疾行 0.23°/天 大于时为疾行速度，小于时为正常
  // #   木星留行 速度节点为“0.011” 小于时开始成为“留行”
  // # 木星逆行节点 -0.022°/天
  // #   木星最快  0.236°/天  最慢-0.134°/天
  //
  // # 水星 最快  2.2°/天   最慢 -1.348°/天【常】
  // #   水星迟行 速度节点为“0.868” 大于时为正常速度，小于时为迟行
  // #   水星疾行 速度节点"1.499",大于时为疾行速度，小于时为正常
  // #   水星留行 速度节点"0.129",大 小于时开始成为“留行”
  // # 水星逆行 -0.089°/天
  //
  // # 土星 最快  0.122°/天  最慢 -0.075°/天
  // #  土星没有迟与疾
  // #   土星留行 速度节点"0.019",大 小于时开始成为“留行”
  // #   土星逆行 节点-0.012°/天
}
