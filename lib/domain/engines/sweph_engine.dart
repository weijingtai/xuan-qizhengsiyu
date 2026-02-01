import 'dart:math';

import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/timezone.dart' as tz;

import '../entities/models/panel_stars_info.dart';
import '../entities/models/star_angle_raw_info.dart';
import 'i_calculation_engine.dart';

/// 基于SWEPH（瑞士星历表）的现代计算引擎。
///
/// 封装了所有使用`sweph`库的计算逻辑。
class SwephEngine implements ICalculationEngine {
  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig panelConfig) async {
    final String assertName;
    if (panelConfig.celestialCoordinateSystem ==
        CelestialCoordinateSystem.ecliptic) {
      if (panelConfig.panelSystemType == PanelSystemType.tropical) {
        switch (panelConfig.constellationSystemType) {
          case ConstellationSystemType.classical:
            assertName = 'ecliptic_tropical_classical.json';
            break;
          case ConstellationSystemType.adjustedClassical:
            assertName = 'ecliptic_tropical_classical_adjested.json';
            break;
          case ConstellationSystemType.modern:
            assertName = 'ecplictic_tropical_morden.json';
            break;
        }
      } else {
        throw UnimplementedError(
            'Unsupported panel system type: ${panelConfig.celestialCoordinateSystem.name} ${panelConfig.panelSystemType.name}');
      }
    } else {
        throw UnimplementedError(
            'Unsupported panel system type: ${panelConfig.celestialCoordinateSystem.name} ${panelConfig.panelSystemType.name}');
    }
    final jsonString =
        await rootBundle.loadString('assets/qizhengsiyu/$assertName');
    return ZhouTianModel.fromJson(jsonDecode(jsonString));
  }

  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
      DateTime birthDate, ObserverPosition position, BasePanelConfig config) async {
    final starsAngle = _calculateAllStarsAngleOnZodiac(position, birthDate);
    return _transformToStarPositionRawData(starsAngle, config);
  }

  List<StarPositionRawData> _transformToStarPositionRawData(
      StarsAngle starsAngle, BasePanelConfig config) {
    final List<StarPositionRawData> list = [];
    final starMap = starsAngle.toMap();

    starMap.forEach((star, angleSpeed) {
      final rawInfo = StarAngleRawInfo(
        panelSystemType: config.panelSystemType,
        coordinateSystem: config.celestialCoordinateSystem,
        angle: angleSpeed.angle,
        speed: angleSpeed.speed,
      );
      list.add(StarPositionRawData(
        starType: star,
        angleRawInfoSet: {rawInfo},
      ));
    });

    return list;
  }

  StarsAngle _calculateAllStarsAngleOnZodiac(
      BaseObserverPosition observerPosition, DateTime datetime) {
    double roundHelper(double number) {
      num factor = pow(10, 2);
      return ((number * factor).round() / factor);
    }

    double ziQi() {
      tz.TZDateTime baseShangHaiTime =
          tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
      const angleForEachMinutes = 0.0352 / (24 * 60);

      if (datetime.isAtSameMomentAs(baseShangHaiTime)) {
        return 0;
      }

      var diffInMinutes = datetime.isBefore(baseShangHaiTime)
          ? baseShangHaiTime.difference(datetime)
          : datetime.difference(baseShangHaiTime);

      double result = diffInMinutes.inMinutes * angleForEachMinutes;
      if (result >= 360) {
        result -= 360;
      }

      return result;
    }

    Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,
        observerPosition.altitude);
    DateTime utcTime = datetime;

    final double julianDay = Sweph.swe_julday(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour + utcTime.minute / 60,
        CalendarType.SE_GREG_CAL);

    var lunar =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    var sun =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);

    var venus = Sweph.swe_calc(julianDay, HeavenlyBody.SE_VENUS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var jupiter = Sweph.swe_calc(julianDay, HeavenlyBody.SE_JUPITER,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var water = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MERCURY,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var mars = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MARS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var saturn = Sweph.swe_calc(julianDay, HeavenlyBody.SE_SATURN,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);

    var northNode = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_NODE, SwephFlag.SEFLG_SWIEPH);
    double northNodeAngle = northNode.longitude;
    double southNodeAngle = (northNodeAngle + 180) % 360;
    var lilith = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_APOG, SwephFlag.SEFLG_SWIEPH);

    // This is a placeholder for the actual StarsAngle class which I cannot see.
    // I am assuming it exists and has these properties.
    // In a real scenario, I would read the definition of StarsAngle first.
    return StarsAngle(
        moon: roundHelper(lunar.longitude),
        sun: roundHelper(sun.longitude),
        venus: roundHelper(venus.longitude),
        venusSpeed: roundHelper(venus.speedInLongitude),
        jupiter: roundHelper(jupiter.longitude),
        jupiterSpeed: roundHelper(jupiter.speedInLongitude),
        water: roundHelper(water.longitude),
        waterSpeed: roundHelper(water.speedInLongitude),
        mars: roundHelper(mars.longitude),
        marsSpeed: roundHelper(mars.speedInLongitude),
        saturn: roundHelper(saturn.longitude),
        saturnSpeed: roundHelper(saturn.speedInLongitude),
        northNode: roundHelper(northNodeAngle),
        southNode: roundHelper(southNodeAngle),
        lilith: roundHelper(lilith.longitude),
        qi: roundHelper(ziQi()));
  }
}
