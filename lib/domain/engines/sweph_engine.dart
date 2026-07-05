import 'dart:math';
import 'dart:convert';

import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/timezone.dart' as tz;

import '../entities/models/panel_stars_info.dart';
import '../entities/models/star_angle_raw_info.dart';
import 'i_calculation_engine.dart';
import 'siyu/si_yu_calculator.dart';
import 'siyu/sweph_si_yu_ephemeris_source.dart';
import 'siyu/ziqi/zi_qi_algorithm.dart';

/// 基于SWEPH（瑞士星历表）的现代计算引擎。
///
/// 域层核心逻辑；资源加载通过 [_ephemerisRes] 委托到存储适配器。
class SwephEngine implements ICalculationEngine {
  final QiZhengEphemerisResourceRepository _ephemerisRes;

  SwephEngine({required QiZhengEphemerisResourceRepository ephemerisRes})
      : _ephemerisRes = ephemerisRes;

  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig panelConfig) async {
    final String assertName;
    if (panelConfig.celestialCoordinateSystem ==
        CelestialCoordinateSystem.Ecliptic) {
      if (panelConfig.panelSystemType == PanelSystemType.Tropical) {
        switch (panelConfig.constellationSystemType) {
          case ConstellationSystemType.Classical:
            assertName = 'ecliptic_tropical_classical.json';
            break;
          case ConstellationSystemType.AdjustedClassical:
            assertName = 'ecliptic_tropical_classical_adjested.json';
            break;
          case ConstellationSystemType.Modern:
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
    final jsonString = await _ephemerisRes.loadEphemerisResource(assertName);
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
    final starMap = starsAngle.toMap(convention: config.rahuKetuConvention);

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

    final siyu = const SiYuCalculator(
      source: SwephSiYuEphemerisSource(),
      ziQiAlgorithm: _TransitionZiQiAlgorithm(),
    ).compute(julianDay: julianDay, birthDate: datetime);

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
        northNode: roundHelper(siyu.northNode),
        southNode: roundHelper(siyu.southNode),
        lilith: roundHelper(siyu.lilith),
        qi: roundHelper(siyu.qi));
  }
}

class _TransitionZiQiAlgorithm implements ZiQiAlgorithm {
  const _TransitionZiQiAlgorithm();
  @override
  String get id => 'transition';
  @override
  double computeLongitude({required double julianDay, required DateTime datetime}) {
    final tz.TZDateTime baseShangHaiTime =
        tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
    const angleForEachMinutes = 0.0352 / (24 * 60);

    if (datetime.isAtSameMomentAs(baseShangHaiTime)) {
      return 0;
    }
    final diffInMinutes = datetime.isBefore(baseShangHaiTime)
        ? baseShangHaiTime.difference(datetime)
        : datetime.difference(baseShangHaiTime);

    double result = diffInMinutes.inMinutes * angleForEachMinutes;
    if (result >= 360) {
      result -= 360;
    }
    return result;
  }
}
