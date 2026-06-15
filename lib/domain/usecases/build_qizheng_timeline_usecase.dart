import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/helpers/solar_time_calculator.dart';
import 'package:metaphysics_core/helpers/solar_lunar_datetime_helper.dart';
import 'package:metaphysics_core/utils/celestial_rise_set_calculator.dart';
import 'package:metaphysics_core/adapters/lunar_adapter.dart';
import 'package:metaphysics_core/models/calculation_strategy_config_logic_model.dart';
import 'package:metaphysics_core/enums/datetime_strategy_enums.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/rise_set_display_data.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/services/generate_base_panel_service.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:timezone/timezone.dart' as tz;

class BuildQiZhengTimelineResult {
  final ChineseDateInfo birthDateInfo;
  final RiseSetDisplayData? riseSetData;
  final PassageYearPanelModel? passageYearPanel;
  final Map<EnumStars, StarAngleSpeed>? fateStarAngleMapper;

  BuildQiZhengTimelineResult({
    required this.birthDateInfo,
    this.riseSetData,
    this.passageYearPanel,
    this.fateStarAngleMapper,
  });
}

class BuildQiZhengTimelineUseCase {
  final ShenShaManager shenShaManager;
  final HuaYaoManager huaYaoManager;

  BuildQiZhengTimelineUseCase({
    required this.shenShaManager,
    required this.huaYaoManager,
  });

  Future<BuildQiZhengTimelineResult> execute({
    required ObserverPosition lifeObserver,
    required BasePanelModel? basicLifePanel,
    ObserverPosition? fateObserver,
    String? locationName,
  }) async {
    final birthDateInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfoV2(
      lifeObserver.dateTime,
      CalculationStrategyConfigLogicModel.defaultConfig.copyWith(
        ziStrategy: ZiShiStrategy.noDistinguishAt23,
      ),
    );

    final riseSetData = _computeRiseSetData(lifeObserver, locationName);

    PassageYearPanelModel? passageYearPanel;
    Map<EnumStars, StarAngleSpeed>? fateStarAngleMapper;

    if (fateObserver != null && basicLifePanel != null) {
      final config = BasePanelConfig.defaultBasicPanelConfig();
      final panelService = GenerateBasePanelService(
        panelConfig: config,
        observerPosition: lifeObserver,
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
      );

      final engine = CalculationEngineFactory.create(config);
      final zhouTianModel = await engine.getSystemDefinition(config);
      final starPositions = await engine.calculateStarPositions(
        fateObserver.dateTime,
        fateObserver,
        config,
      );

      fateStarAngleMapper = _transformStarPositions(starPositions, config);

      passageYearPanel = await panelService.calculateDaXia(
        basicLifePanel,
        fateObserver,
        zhouTianModel: zhouTianModel,
        starAngleMapper: fateStarAngleMapper,
      );
    }

    return BuildQiZhengTimelineResult(
      birthDateInfo: birthDateInfo,
      riseSetData: riseSetData,
      passageYearPanel: passageYearPanel,
      fateStarAngleMapper: fateStarAngleMapper,
    );
  }

  Map<EnumStars, StarAngleSpeed> _transformStarPositions(
      List<StarPositionRawData> starPositions, BasePanelConfig config) {
    final Map<EnumStars, StarAngleSpeed> mapper = {};
    for (final pos in starPositions) {
      final matchingInfo = pos.angleRawInfoSet.firstWhere(
        (info) =>
            info.panelSystemType == config.panelSystemType &&
            info.coordinateSystem == config.celestialCoordinateSystem,
        orElse: () => pos.angleRawInfoSet.first,
      );
      mapper[pos.starType] = StarAngleSpeed(
        angle: matchingInfo.angle,
        speed: matchingInfo.speed,
      );
    }
    return mapper;
  }

  RiseSetDisplayData? _computeRiseSetData(
      ObserverPosition observer, String? locationName) {
    try {
      final dailyInfo = CelestialRiseSetCalculator.calculateDaily(
        utcDateTime: observer.utcDateTime,
        longitude: observer.longitude,
        latitude: observer.latitude,
        altitude: observer.altitude,
      );

      final locTimezone = tz.getLocation(observer.timezone);
      DateTime? toLocal(DateTime? utc) =>
          utc != null ? tz.TZDateTime.from(utc, locTimezone) : null;

      final trueSolarTime = SolarTimeCalculator(
        dateTime: observer.utcDateTime,
        longitude: observer.longitude,
      ).getTrueSolarTime();

      final lunar = LunarAdapter.fromDate(observer.dateTime);
      final lunarDateString =
          '${lunar.getYearInGanZhi()}年${lunar.getMonthInChinese()}${lunar.getDayInChinese()}日';
      final lunarTimeString = '${lunar.getTimeZhi()}时';
      final jieQiInfo = lunar.getJieQi();

      return RiseSetDisplayData(
        sunRise: toLocal(dailyInfo.sun.rise),
        sunSet: toLocal(dailyInfo.sun.set_),
        moonRise: toLocal(dailyInfo.moon.rise),
        moonSet: toLocal(dailyInfo.moon.set_),
        trueSolarTime: trueSolarTime,
        longitude: observer.longitude,
        latitude: observer.latitude,
        timezone: observer.timezone,
        lunarDateString: lunarDateString,
        lunarTimeString: lunarTimeString,
        isDayBirth: observer.isDayBirth,
        fourPillarsDisplay: observer.fourZhuEightChar,
        localDateTime: observer.dateTime,
        locationName: locationName ?? '',
        jieQiInfo: jieQiInfo,
      );
    } catch (e) {
      return null;
    }
  }
}
