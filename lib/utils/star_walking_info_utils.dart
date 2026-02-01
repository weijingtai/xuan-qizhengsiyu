import 'package:common/enums.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:sweph/sweph.dart';
import 'package:tuple/tuple.dart';

import '../domain/entities/models/observer_position.dart'; // 使用domain层的ObserverPosition
import '../domain/entities/models/stars_angle.dart'; // 使用domain层的模型

class StarWalkingInfoUtils {
  static FiveStarWalkingInfo calculateStarWalkingInfo(
      EnumStars fiveStar,
      ObserverPosition observerPosition,
      Map<EnumStars, Tuple6<double, double, double, double, double?, double?>>
          mapper) {
    Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,
        observerPosition.altitude);
    DateTime utcTime = observerPosition.dateTime;

    final double julianDay = Sweph.swe_julday(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour + utcTime.minute / 60,
        CalendarType.SE_GREG_CAL);

    HeavenlyBody planetBody = getHeavenlyBodyByEnumSeven(fiveStar);
    var planetInfo = Sweph.swe_calc(
        julianDay, planetBody, SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);

    // tuple6.item1 最快速度，item2 逆行最快，item3 逆行，item4 留行，item5疾行，item6 迟行

    int speedStringFixed = 3;
    double observerAngle =
        double.parse(planetInfo.longitude.toStringAsFixed(2));
    double observerSpeed = double.parse(
        planetInfo.speedInLongitude.toStringAsFixed(speedStringFixed));
    Tuple6<double, double, double, double, double?, double?> tuple6 =
        mapper[fiveStar]!;
    double maxSpeed = tuple6.item1;
    double retrogradeMaxSpeed = tuple6.item2;
    double timeStep = 2 / 24;
    FiveStarWalkingType currentFiveStarWalkingType =
        getWalkingType(observerSpeed, tuple6);

    List<FiveStarWalkingType> walkingSeqForward =
        QiZhengSiYuConstantResources.getFullForwardList(fiveStar);

    List<FiveStarWalkingType> reversedSeq =
        FiveStarWalkingType.reverseToPreviousListAndChangeFirst(
            currentFiveStarWalkingType, walkingSeqForward.reversed.toList());
    FiveStarWalkingType reversedStarWalkingType = currentFiveStarWalkingType;
    double reversedJulianDay = julianDay;
    List<StarWalkingInfo> prevWalkingTypeList = [];
    for (var i = 0; i < reversedSeq.length; i++) {
      StarWalkingInfo inf = prevWalkingType(fiveStar, planetBody, observerSpeed,
          reversedJulianDay, reversedStarWalkingType, tuple6,
          speedStringFixed: speedStringFixed, timeStep: timeStep);
      reversedJulianDay = datetimeToJulday(inf.walkingTypeStartAt);
      reversedStarWalkingType = inf.walkingType;
      prevWalkingTypeList.add(inf);
    }
    prevWalkingTypeList = prevWalkingTypeList.reversed.toList();
    // prevWalkingTypeList.forEach((p){
    //   print(p);
    // });

    // print("$utcTime ${planetInfo.longitude.toStringAsFixed(2)}° $observerSpeed°/天 ${currentFiveStarWalkingType.name}");

    List<FiveStarWalkingType> forwardSeq = FiveStarWalkingType.changeFirst(
        currentFiveStarWalkingType, walkingSeqForward);
    FiveStarWalkingType forwardStarWalkingType = currentFiveStarWalkingType;
    double forwardJulianDay = julianDay;
    List<StarWalkingInfo> nextWalkingTypeList = [];
    for (var i = 0; i < forwardSeq.length; i++) {
      StarWalkingInfo inf = nextWalkingType(fiveStar, planetBody, observerSpeed,
          forwardJulianDay, forwardStarWalkingType, tuple6,
          speedStringFixed: speedStringFixed, timeStep: timeStep);
      forwardJulianDay = datetimeToJulday(inf.walkingTypeStartAt);
      forwardStarWalkingType = inf.walkingType;
      nextWalkingTypeList.add(inf);
      // print(inf);
    }
    // forwardSeq inf =  nextWalkingType(fiveStar,planetBody,observerSpeed, julianDay, currentFiveStarWalkingType, tuple6, speedStringFixed: _speedStringFixed,timeStep: timeStep);
    return FiveStarWalkingInfo(
      star: fiveStar,
      maxSpeed: maxSpeed,
      angle: observerAngle,
      walkingType: currentFiveStarWalkingType,
      walkingTypeStartAt: utcTime,
      walkingTypeEndAt: nextWalkingTypeList.first.walkingTypeStartAt,
      reversedSpeedThresholdAt: tuple6.item3,
      staySpeedThresholdAt: tuple6.item4,
      fastSpeedThresholdAt: tuple6.item5,
      lowSpeedThresholdAt: tuple6.item6,
      nextSeq: nextWalkingTypeList,
      prevSeq: prevWalkingTypeList,
      speedThresholdName: "moira",
      retrogradeMaxSpeed: retrogradeMaxSpeed,
    );

    // var Jupiter = Sweph.swe_calc(julianDay, HeavenlyBody.SE_JUPITER, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    // var water = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MERCURY, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    // var Mars = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MARS, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    // var Saturn = Sweph.swe_calc(julianDay, HeavenlyBody.SE_SATURN, SwephFlag.SEFLG_SWIEPH|SwephFlag.SEFLG_SPEED);
    // print(Venus.speedInLongitude);
  }

  static StarWalkingInfo prevWalkingType(
      EnumStars fiveStar,
      HeavenlyBody planetBody,
      double observerSpeed,
      double julianDay,
      FiveStarWalkingType currentFiveStarWalkingType,
      Tuple6<double, double, double, double, double?, double?> tuple6,
      {int speedStringFixed = 3,
      double timeStep = 2 / 24}) {
    double prevForwardSpeed = observerSpeed;
    FiveStarWalkingType prevForwardType = currentFiveStarWalkingType;
    double prevForwardJD = julianDay;
    double finalAngle = 0;
    while (prevForwardType == currentFiveStarWalkingType) {
      var planetInfo = Sweph.swe_calc(prevForwardJD, planetBody,
          SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
      double speed = double.parse(
          planetInfo.speedInLongitude.toStringAsFixed(speedStringFixed));
      if (speed == prevForwardSpeed) {
        prevForwardJD -= timeStep;
        continue;
      }
      prevForwardSpeed = speed;
      // print("object $prevForwardSpeed ${_speed == prevForwardSpeed}");
      // if (_speed>=maxSpeed||_speed<=retrogradeMaxSpeed){
      //   print("${juldayToDatetime(prevForwardJD)} ${planetInfo.longitude.toStringAsFixed(2)}° ${_speed}°/天 max");
      //   break;
      // }
      FiveStarWalkingType type = getWalkingType(prevForwardSpeed, tuple6);
      DateTime time = juldayToDatetime(prevForwardJD);
      if (prevForwardType == type) {
        prevForwardJD -= timeStep;
        continue;
      }
      prevForwardType = type;
      prevForwardJD -= timeStep;
      finalAngle = double.parse(planetInfo.longitude.toStringAsFixed(2));
      // print("$_time ${planetInfo.longitude.toStringAsFixed(2)}° $_speed°/天 ${prevForwardType.name}");
    }
    return StarWalkingInfo(
        star: fiveStar,
        walkingType: prevForwardType,
        walkingTypeStartAt: juldayToDatetime(prevForwardJD),
        speed: prevForwardSpeed,
        angle: finalAngle);
  }

  static StarWalkingInfo nextWalkingType(
      EnumStars fiveStar,
      HeavenlyBody planetBody,
      double observerSpeed,
      double julianDay,
      FiveStarWalkingType currentFiveStarWalkingType,
      Tuple6<double, double, double, double, double?, double?> tuple6,
      {int speedStringFixed = 3,
      double timeStep = 2 / 24}) {
    double prevForwardSpeed = observerSpeed;
    FiveStarWalkingType prevForwardType = currentFiveStarWalkingType;
    double prevForwardJD = julianDay;
    double finalAngle = 0;
    while (prevForwardType == currentFiveStarWalkingType) {
      var planetInfo = Sweph.swe_calc(prevForwardJD, planetBody,
          SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
      double speed = double.parse(
          planetInfo.speedInLongitude.toStringAsFixed(speedStringFixed));
      if (speed == prevForwardSpeed) {
        prevForwardJD += timeStep;
        continue;
      }
      prevForwardSpeed = speed;
      // print("object $prevForwardSpeed ${_speed == prevForwardSpeed}");
      // if (_speed>=maxSpeed||_speed<=retrogradeMaxSpeed){
      //   print("${juldayToDatetime(prevForwardJD)} ${planetInfo.longitude.toStringAsFixed(2)}° ${_speed}°/天 max");
      //   break;
      // }
      FiveStarWalkingType type = getWalkingType(prevForwardSpeed, tuple6);
      // DateTime _time = juldayToDatetime(prevForwardJD);
      if (prevForwardType == type) {
        prevForwardJD += timeStep;
        continue;
      }
      prevForwardType = type;
      prevForwardJD += timeStep;
      finalAngle = double.parse(planetInfo.longitude.toStringAsFixed(2));
      // print("${planetInfo.longitude.toStringAsFixed(2)}° $_speed°/天 ${prevForwardType.name}");
    }
    return StarWalkingInfo(
        star: fiveStar,
        walkingType: prevForwardType,
        walkingTypeStartAt: juldayToDatetime(prevForwardJD),
        speed: prevForwardSpeed,
        angle: finalAngle);
  }

  static HeavenlyBody getHeavenlyBodyByEnumSeven(EnumStars fiveStar) {
    HeavenlyBody planetBody = HeavenlyBody.SE_EARTH;
    switch (fiveStar) {
      case EnumStars.Venus:
        planetBody = HeavenlyBody.SE_VENUS;
        break;
      case EnumStars.Jupiter:
        planetBody = HeavenlyBody.SE_JUPITER;
        break;
      case EnumStars.Mercury:
        planetBody = HeavenlyBody.SE_MERCURY;
        break;
      case EnumStars.Mars:
        planetBody = HeavenlyBody.SE_MARS;
        break;
      case EnumStars.Saturn:
        planetBody = HeavenlyBody.SE_SATURN;
        break;
      default:
        break;
    }
    return planetBody;
  }

  static double datetimeToJulday(DateTime utcTime) {
    return Sweph.swe_julday(utcTime.year, utcTime.month, utcTime.day,
        utcTime.hour + utcTime.minute / 60, CalendarType.SE_GREG_CAL);
  }

  static DateTime juldayToDatetime(double julianDay) {
    return Sweph.swe_revjul(julianDay, CalendarType.SE_GREG_CAL);
  }

  static FiveStarWalkingType getWalkingTypeByThreshold(
      double observerSpeed, StarWalkingTypeThreshold threshold) {
    double maxSpeed = threshold.maxSpeed;
    double retrogradeMaxSpeed = threshold.maxRetrogradeThreshold;

    double retrogradeThreshold = threshold.retrogradeThreshold;
    double stayThreshold = threshold.stayThreshold;
    double? fastThreshold = threshold.fastThreshold;
    double? slowThreshold = threshold.slowThreshold;
    FiveStarWalkingType walkingType = FiveStarWalkingType.Normal;

    // print("[$observerSpeed] revs:$retrogradeThreshold stay:$stayThreshold fast:$fastThreshold slow:$slowThreshold");
    if (observerSpeed < retrogradeThreshold) {
      walkingType = FiveStarWalkingType.Retrograde;
    } else if (fastThreshold != null && observerSpeed > fastThreshold) {
      walkingType = FiveStarWalkingType.Fast;
    } else if (observerSpeed < stayThreshold) {
      walkingType = FiveStarWalkingType.Stay;
    } else if (slowThreshold != null && observerSpeed < slowThreshold) {
      walkingType = FiveStarWalkingType.Slow;
    }
    return walkingType;
  }

  static FiveStarWalkingType getWalkingType(double observerSpeed,
      Tuple6<double, double, double, double, double?, double?> tuple6) {
    double maxSpeed = tuple6.item1;
    double retrogradeMaxSpeed = tuple6.item2;

    double retrogradeThreshold = tuple6.item3;
    double stayThreshold = tuple6.item4;
    double? fastThreshold = tuple6.item5;
    double? slowThreshold = tuple6.item6;
    FiveStarWalkingType walkingType = FiveStarWalkingType.Normal;

    // print("[$observerSpeed] revs:$retrogradeThreshold stay:$stayThreshold fast:$fastThreshold slow:$slowThreshold");
    if (observerSpeed < retrogradeThreshold) {
      walkingType = FiveStarWalkingType.Retrograde;
    } else if (fastThreshold != null && observerSpeed > fastThreshold) {
      walkingType = FiveStarWalkingType.Fast;
    } else if (observerSpeed < stayThreshold) {
      walkingType = FiveStarWalkingType.Stay;
    } else if (slowThreshold != null && observerSpeed < slowThreshold) {
      walkingType = FiveStarWalkingType.Slow;
    }
    return walkingType;
  }
}
