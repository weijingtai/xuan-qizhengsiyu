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

import 'package:metaphysics_core/enums.dart';
import '../entities/models/panel_stars_info.dart';
import '../entities/models/star_angle_raw_info.dart';
import 'i_calculation_engine.dart';
import 'siyu/si_yu_calculator.dart';
import 'siyu/sweph_si_yu_ephemeris_source.dart';
import 'siyu/ziqi/zi_qi_algorithm.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'siyu/ziqi/guolao_zi_qi_algorithm.dart';
import 'siyu/ziqi/shixian_zi_qi_algorithm.dart';
import 'siyu/ziqi/tianguan_zi_qi_algorithm.dart';
import 'siyu/ziqi/ziqi_epoch_calibrator.dart';
import 'siyu/ziqi/solar_term_julian_day.dart';
import 'siyu/ziqi/zi_qi_algorithm_registry.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_algorithm_factory.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/si_yu_config_resolver.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_calculator.dart';

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
    } else if (panelConfig.celestialCoordinateSystem ==
        CelestialCoordinateSystem.SkyEquatorial) {
      assertName = 'yuan_shoushi_chidao_hengxin.json';
    } else {
      throw UnimplementedError(
          'Unsupported panel system type: ${panelConfig.celestialCoordinateSystem.name} ${panelConfig.panelSystemType.name}');
    }
    final jsonString = await _ephemerisRes.loadEphemerisResource(assertName);
    return ZhouTianModel.fromJson(jsonDecode(jsonString)).applyOverrides(
        panelConfig.zhouTianModelOverride,
        panelConfig.projectionOverride);
  }

  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
      DateTime birthDate, ObserverPosition position, BasePanelConfig config) async {
    final zhouTianModel = await getSystemDefinition(config);
    final starsAngle = _calculateAllStarsAngleOnZodiac(position, birthDate, zhouTianModel, config);
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
      BaseObserverPosition observerPosition, DateTime datetime, ZhouTianModel zhouTianModel, BasePanelConfig config) {
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

    final double guoLaoEpochJd;
    final double guoLaoEpochLon;
    final double guoLaoPeriod;

    final String profileId = config.siYuProfileId;
    final Map<SiYuGroup, SiYuGroupSpec> resolvedGroups;
    final CelestialCoordinateSystem coordinate = config.siYuCoordinateOverride ?? config.celestialCoordinateSystem;
    final double totalDegree = coordinate == CelestialCoordinateSystem.Ecliptic ? 360.0 : 365.25;

    if (profileId == 'guolao_ecliptic' && config.siYuOverrides.isEmpty) {
      // Legacy compatibility mode / dynamic default
      final double ziqiEpochJd;
      final double ziqiEpochLon;
      final double ziqiDailyMotion;
      final String ziqiKind;

      if (config.ziQiAlgorithm == EnumZiQiAlgorithm.yelvTianguan) {
        ziqiKind = 'yelv_tianguan_ziqi';
        ziqiEpochJd = 0;
        ziqiEpochLon = 0;
        ziqiDailyMotion = 0;
      } else if (config.ziQiAlgorithm == EnumZiQiAlgorithm.shixian) {
        ziqiKind = 'shixian_ziqi';
        ziqiEpochJd = 0;
        ziqiEpochLon = 0;
        ziqiDailyMotion = 0;
      } else {
        ziqiKind = 'linear_ziqi';
        if (coordinate == CelestialCoordinateSystem.SkyEquatorial &&
            config.ziQiChiDaoStandard == EnumZiQiChiDaoStandard.moira) {
          ziqiEpochJd = 2461226.135;
          ziqiEpochLon = 333.843;
          ziqiDailyMotion = totalDegree / 10237.7;
        } else {
          ziqiDailyMotion = totalDegree / config.ziQiPeriod.days;
          switch (config.ziQiEpochSet) {
            case EnumZiQiEpochSet.shouShiNvXiu:
              ziqiEpochJd = Sweph.swe_julday(
                  1280, 12, 14, 1 + 29 / 60 + 36 / 3600, CalendarType.SE_JUL_CAL);
              ziqiEpochLon = (totalDegree == 365.25) ? 1.884975 : 295.0;
              break;
            case EnumZiQiEpochSet.fuTianJiXiu:
              ziqiEpochJd = winterSolsticeJulianDay(1281, julianCalendar: true);
              final jiXiuStart = _jiXiuStartLongitude(zhouTianModel);
              ziqiEpochLon = ZiqiEpochCalibrator.fromConstellationPipeline(
                  jiXiuStartLongitude: jiXiuStart, totalDegree: totalDegree);
              break;
          }
        }
      }

      resolvedGroups = {
        SiYuGroup.luoJi: SiYuGroupSpec(
          kind: 'ephemeris_node',
          rahuKetuConventionIndex: config.rahuKetuConvention.index,
        ),
        SiYuGroup.yueBo: const SiYuGroupSpec(kind: 'ephemeris_apogee'),
        SiYuGroup.ziQi: SiYuGroupSpec(
          kind: ziqiKind,
          params: {
            'totalDegree': totalDegree,
            'dailyMotion': ziqiDailyMotion,
            'epochJulianDay': ziqiEpochJd,
            'epochPosition': ziqiEpochLon,
          },
        ),
      };
    } else {
      final resolved = SiYuConfigResolver().resolve(
        profileId: profileId,
        overrides: config.siYuOverrides.map(
            (k, v) => MapEntry(SiYuGroup.values.byName(k), v)),
        coordinateOverride: config.siYuCoordinateOverride,
      );
      resolvedGroups = resolved.groups;
    }

    final factory = SiYuAlgorithmFactory.withDefaults();
    final ctx = CoordinateContext(
        totalDegree: totalDegree, ephemerisSource: const SwephSiYuEphemerisSource());
    
    final siYuPos = <EnumStars, double>{};
    for (final g in SiYuGroup.values) {
      final spec = resolvedGroups[g];
      if (spec != null) {
        siYuPos.addAll(factory
            .build(spec, ctx)
            .computePositions(julianDay: julianDay, datetime: datetime));
      }
    }

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
        northNode: roundHelper(siYuPos[EnumStars.Luo] ?? siYuPos[EnumStars.Ji]! - 180.0), // fallback if not computed, though always computed
        southNode: roundHelper(siYuPos[EnumStars.Ji] ?? siYuPos[EnumStars.Luo]! - 180.0),
        lilith: roundHelper(siYuPos[EnumStars.Bei] ?? 0.0),
        qi: roundHelper(siYuPos[EnumStars.Qi] ?? 0.0));
  }

  double _jiXiuStartLongitude(ZhouTianModel zhouTianModel) {
    return ZhouTianCalculator.getStartEquatorialLon(
        zhouTianModel, Enum28Constellations.Ji_Shui_Bao);
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
