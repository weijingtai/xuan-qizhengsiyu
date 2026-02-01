import 'dart:math' as math;

import 'package:sweph/sweph.dart';
import 'package:common/enums.dart';

import '../../enums/enum_panel_system_type.dart';
import '../entities/models/star_angle_raw_info.dart';


abstract class StarAngleStrategy {
  StarAngleRawInfo calculate(
      EnumStars star, double julianDay, List<double> geopos);
}

class EquatorialSiderealStrategy implements StarAngleStrategy {
  // 赤道恒星制
  @override
  StarAngleRawInfo calculate(
      EnumStars star, double julianDay, List<double> geopos) {
    // SE_SIDM_LAHIRI 瑞士星例表
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);

    CoordinatesWithSpeed result = Sweph.swe_calc_ut(
        julianDay,
        swephStar,
        SwephFlag.SEFLG_TOPOCTR |
            SwephFlag.SEFLG_SIDEREAL |
            SwephFlag.SEFLG_SPEED |
            SwephFlag.SEFLG_EQUATORIAL);

    return StarAngleRawInfo(
      panelSystemType: PanelSystemType.sidereal,
      coordinateSystem: CelestialCoordinateSystem.equatorial,
      angle: result.longitude, // 赤经
      speed: result.speedInLongitude, // 赤经速度
    );
  }
}

class EquatorialTropicalStrategy implements StarAngleStrategy {
  // 赤道回归制
  @override
  StarAngleRawInfo calculate(
      EnumStars star, double julianDay, List<double> geopos) {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_J2000);
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);

    final result = Sweph.swe_calc_ut(
        julianDay,
        swephStar,
        SwephFlag.SEFLG_TOPOCTR |
            SwephFlag.SEFLG_SPEED |
            SwephFlag.SEFLG_EQUATORIAL);

    return StarAngleRawInfo(
      panelSystemType: PanelSystemType.tropical,
      coordinateSystem: CelestialCoordinateSystem.equatorial,
      angle: result.longitude, // 赤经
      speed: result.speedInLongitude, // 赤经速度
    );
  }
}

class EclipticSiderealStrategy implements StarAngleStrategy {
  // 黄道恒星制
  StarAngleRawInfo calculate(
      EnumStars star, double julianDay, List<double> geopos) {
    // final sweph = Sweph();
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI); // 设置恒星黄道
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);

    CoordinatesWithSpeed result = Sweph.swe_calc_ut(
        julianDay,
        swephStar,
        SwephFlag.SEFLG_TOPOCTR |
            SwephFlag.SEFLG_SIDEREAL |
            SwephFlag.SEFLG_SPEED |
            SwephFlag.SEFLG_XYZ); // 使用黄道坐标标志和恒星制标志

    return StarAngleRawInfo(
      panelSystemType: PanelSystemType.sidereal,
      coordinateSystem: CelestialCoordinateSystem.ecliptic,
      angle: result.longitude, // 黄经
      speed: result.speedInLongitude, // 黄经速度
    );
  }
}

class EclipticTropicalStrategy implements StarAngleStrategy {
  // 黄道回归制
  @override
  StarAngleRawInfo calculate(
      EnumStars star, double julianDay, List<double> geopos) {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_J2000); // 设置回归黄道
    Sweph.swe_set_topo(geopos[0], geopos[1], geopos[2]);

    final swephStar = _getSwephStar(star);
    CoordinatesWithSpeed result = Sweph.swe_calc_ut(julianDay, swephStar,
        SwephFlag.SEFLG_TROPICAL | SwephFlag.SEFLG_SPEED); // 使用黄道坐标标志

    // double degrees = result.longitude * 180 / math.pi;

    return StarAngleRawInfo(
      panelSystemType: PanelSystemType.tropical,
      coordinateSystem: CelestialCoordinateSystem.ecliptic,
      angle: result.longitude, // 黄经
      speed: result.speedInLongitude, // 黄经速度
    );
  }
}

HeavenlyBody _getSwephStar(EnumStars star) {
  switch (star) {
    case EnumStars.Sun:
      return HeavenlyBody.SE_SUN;
    case EnumStars.Moon:
      return HeavenlyBody.SE_MOON;
    case EnumStars.Mercury:
      return HeavenlyBody.SE_MERCURY;
    case EnumStars.Venus:
      return HeavenlyBody.SE_VENUS;
    case EnumStars.Mars:
      return HeavenlyBody.SE_MARS;
    case EnumStars.Jupiter:
      return HeavenlyBody.SE_JUPITER;
    case EnumStars.Saturn:
      return HeavenlyBody.SE_SATURN;
    case EnumStars.Ji:
      return HeavenlyBody.SE_MEAN_NODE;
    case EnumStars.Bei:
      return HeavenlyBody.SE_MEAN_APOG;
    default:
      throw ArgumentError('Invalid star type');
  }
}
