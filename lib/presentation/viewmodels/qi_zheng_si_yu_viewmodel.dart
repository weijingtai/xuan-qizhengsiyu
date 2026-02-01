import 'package:common/enums/enum_stars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/services/generate_base_panel_service.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart'; // 使用UI分支的版本
import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/hua_yao_repository_impl.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/data/datasources/local/shen_sha_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/shen_sha_repository_impl.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/presentation/pages/StarsResolver.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart'
    as UIPanelConfig; // UI层的PanelConfig
import 'package:common/module.dart'; // DivinationInfoModel
import 'package:common/datamodel/datetime_divination_datamodel.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/datamodel/location.dart';
import 'package:common/enums.dart';
import 'package:uuid/uuid.dart'; // 用于生成UUID

import '../../domain/entities/models/stars_angle.dart'; // 使用domain层模型

/// 七政四余 ViewModel - MVVM架构 + UI兼容层
///
/// 本ViewModel整合了MVVM架构的核心逻辑,同时提供与旧UI层兼容的接口。
/// - 核心架构: 使用 domain/data 分层,依赖注入,UseCase模式
/// - UI兼容层: 提供 ValueNotifier 和兼容方法,确保现有UI无需大改
class QiZhengSiYuViewModel extends ChangeNotifier {
  // ==================== 核心依赖 (MVVM架构) ====================
  final ShenShaManager shenShaManager;
  final HuaYaoManager huaYaoManager;
  final ZhouTianModelManager zhouTianModelManager;

  QiZhengSiYuViewModel({
    required this.shenShaManager,
    required this.huaYaoManager,
    required this.zhouTianModelManager,
  });

  // ==================== 核心状态 (MVVM) ====================
  BasePanelModel? _basicLifePanel;
  BasePanelModel? get basicLifePanel => _basicLifePanel;

  List<UIStarModel> _uiBasicLifeStars = [];
  List<UIStarModel> get uiBasicLifeStars => _uiBasicLifeStars;

  // ==================== UI兼容层: ValueNotifier ====================
  /// 周天模型数据 - 用于 ValueListenableBuilder
  final ValueNotifier<ZhouTianModel?> uiZhouTianModelNotifier =
      ValueNotifier(null);

  /// 本命盘数据 - 用于 ValueListenableBuilder
  final ValueNotifier<BasePanelModel?> uiBasePanelNotifier =
      ValueNotifier(null);

  /// 获取 ValueListenable 类型的 basePanel (用于PanelController)
  ValueListenable<BasePanelModel?> get uiBasePanelListenable =>
      uiBasePanelNotifier;

  /// 大限盘数据 - 用于 ValueListenableBuilder
  final ValueNotifier<PassageYearPanelModel?> uiDaXianPanelNotifier =
      ValueNotifier(null);

  /// 本命星体UI数据 - 用于 ValueListenableBuilder
  final ValueNotifier<List<UIStarModel>?> uiBasicLifeStarsNotifier =
      ValueNotifier(null);

  /// 获取 ValueListenable 类型的 basicLifeStars (用于PanelController)
  ValueListenable<List<UIStarModel>?> get uiBasicLifeStarsListenable =>
      uiBasicLifeStarsNotifier;

  /// 大限星体UI数据 - 用于 ValueListenableBuilder
  final ValueNotifier<List<UIStarModel>?> uiFateLifeStarsNotifier =
      ValueNotifier(null);

  /// 获取 ValueListenable 类型的 fateLifeStars (用于PanelController)
  ValueListenable<List<UIStarModel>?> get uiFateLifeStarsListenable =>
      uiFateLifeStarsNotifier;

  /// 观察者位置数据 - 用于 ValueListenableBuilder
  final ValueNotifier<ObserverPosition?> baseObserverPositionNotifier =
      ValueNotifier(null);

  // ==================== UI兼容层: 普通属性 ====================
  /// 大限星体列表
  List<UIStarModel> _uiFateLifeStars = [];
  List<UIStarModel> get uiFateLifeStars => _uiFateLifeStars;

  /// 大限星体运行状态映射
  Map<EnumStars, FiveStarWalkingInfo>? _daXianMapper;
  Map<EnumStars, FiveStarWalkingInfo>? get daXianMapper => _daXianMapper;

  /// 当前观察者位置(生命起盘时间点)
  ObserverPosition? _lifeObserver;
  ObserverPosition? get lifeObserver => _lifeObserver;

  /// 流年观察者位置
  ObserverPosition? _fateObserver;
  ObserverPosition? get fateObserver => _fateObserver;

  // ==================== UI兼容层: 常量 ====================
  /// UI安全角度额外增加的度数,用于避免星体图标重叠
  static const double _uiSafetyAnglePadding = 2.0;

  /// 紫气计算的基准时间点 (上海时区)
  /// 此计算方法基于特定术数规则,非标准天文计算
  static final tz.TZDateTime _ziQiBaseShangHaiTime =
      tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);

  /// 紫气每日运行角度 (度)
  /// 每24小时运行 02′07″,约等于 0.0352 度
  static const double _ziQiAnglePerDay = 0.0352;

  /// 紫气每分钟运行角度 (度)
  static const double _ziQiAnglePerMinute = _ziQiAnglePerDay / (24 * 60);

  // ==================== UI兼容层: 私有状态 ====================
  /// 本命盘星体的最小安全角度
  double _baseMiniSafetyAngle = 0.0;

  /// 大限盘星体的最小安全角度
  double _fateMiniSafetyAngle = 0.0;

  /// UI层覆盖配置 (用于路由参数传入的配置)
  UIPanelConfig.PanelConfig? _overridePanelConfig;

  // ==================== UI兼容层: 初始化方法 ====================
  /// 初始化 ViewModel
  /// 用于加载周天模型等必要数据
  Future<void> init() async {
    await zhouTianModelManager.load();
    // TODO: 加载其他必要的数据源
  }

  // ==================== UI兼容层: 数据转换方法 ====================
  /// 设置生命观察者位置 - UI兼容方法
  ///
  /// 从 DivinationInfoModel 提取观察者信息并转换为 ObserverPosition
  /// 此方法保持与旧UI层相同的签名
  void setLifeObserver(DivinationInfoModel divinationInfoModel) {
    _lifeObserver = _generateLifeObserverPosition(divinationInfoModel);
    baseObserverPositionNotifier.value = _lifeObserver;
  }

  /// 从 DivinationInfoModel 生成 ObserverPosition
  ObserverPosition _generateLifeObserverPosition(
      DivinationInfoModel divinationInfoModel) {
    DatatimeDivinationDetailsDataModel datetimeData =
        divinationInfoModel.divinationDatetime;

    // 找到对应的占卜时间信息
    DivinationDatetimeModel datetimeModel = datetimeData.timingInfoListJson!
        .firstWhere((t) => t.uuid == datetimeData.timingInfoUuid);

    // 根据观察者类型确定坐标
    Coordinates coordinates;
    switch (datetimeModel.observer.type) {
      case EnumDatetimeType.standard:
      case EnumDatetimeType.removeDST:
        coordinates =
            datetimeModel.observer.location!.address!.province.coordinates;
        break;
      case EnumDatetimeType.meanSolar:
        coordinates =
            datetimeModel.observer.location!.address!.city?.coordinates ??
                datetimeModel.observer.location!.address!.province.coordinates;
        break;
      case EnumDatetimeType.trueSolar:
        if (datetimeModel.observer.isManualCalibration) {
          coordinates = datetimeModel.observer.location!.preciseCoordinates!;
        } else {
          coordinates = datetimeModel.observer.location!.coordinates!;
        }
        break;
    }

    // 构建 ObserverPosition
    return ObserverPosition(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      altitude: 0,
      timezone: datetimeModel.observer.timezoneStr,
      dateTime: datetimeModel.datetime,
      isDayBirth: _getDayTimeZhi().contains(datetimeModel.timeJiaZi.zhi),
      yearGanZhi: datetimeModel.yearJiaZi,
      monthGanZhi: datetimeModel.monthJiaZi,
      dayGanZhi: datetimeModel.dayJiaZi,
      timeGanZhi: datetimeModel.timeJiaZi,
    );
  }

  /// 获取白天地支列表 (用于判断是否日生)
  List<String> _getDayTimeZhi() {
    return ['寅', '卯', '辰', '巳', '午', '未', '申', '酉'];
  }

  // ==================== UI兼容层: 兼容版计算方法 ====================
  /// 计算星盘 - UI兼容版本
  ///
  /// 此方法保持与旧UI层相同的签名,只接受 ObserverPosition
  /// 内部会构建默认配置并调用 MVVM 架构的计算方法
  Future<void> calculate(ObserverPosition observerPosition) async {
    _lifeObserver = observerPosition;
    baseObserverPositionNotifier.value = observerPosition;

    // 如果有override配置,优先使用
    final config = _overridePanelConfig != null
        ? _convertUIPanelConfigToBasePanelConfig(_overridePanelConfig!)
        : _buildDefaultConfig(observerPosition);

    // 调用 MVVM 架构的计算方法
    await calculateWithConfig(config, observerPosition);
  }

  /// 设置覆盖配置 - UI兼容方法
  ///
  /// 允许UI层通过路由参数等方式传入自定义配置
  void setOverridePanelConfig(UIPanelConfig.PanelConfig config) {
    _overridePanelConfig = config;
  }

  /// 将UI层的PanelConfig转换为domain层的BasePanelConfig
  BasePanelConfig _convertUIPanelConfigToBasePanelConfig(
      UIPanelConfig.PanelConfig uiConfig) {
    return BasePanelConfig(
      celestialCoordinateSystem: uiConfig.celestialCoordinateSystem,
      houseDivisionSystem: uiConfig.houseDivisionSystem,
      panelSystemType: uiConfig.panelSystemType,
      constellationSystemType: uiConfig.constellationSystemType,
      settleLifeType: uiConfig.settleLifeType,
      settleBodyType: uiConfig.settleBodyType,
      islifeGongBySunRealTimeLocation: uiConfig.islifeGongBySunRealTimeLocation,
      lifeCountingToGong: uiConfig.lifeCountingToGong,
      bodyCountingToGong: uiConfig.bodyCountingToGong,
    );
  }

  /// 构建默认星盘配置
  /// 从观察者位置推断合理的默认配置
  BasePanelConfig _buildDefaultConfig(ObserverPosition observer) {
    // 使用 BasePanelConfig 提供的默认配置
    return BasePanelConfig.defaultBasicPanelConfig();
  }

  // ==================== MVVM核心: 完整配置版计算方法 ====================
  /// 计算星盘 - MVVM完整版本
  ///
  /// 接受完整的配置和观察者位置,执行MVVM架构的计算流程
  /// 使用 CalculationEngine, GenerateBasePanelService 等
  Future<void> calculateWithConfig(
      BasePanelConfig config, ObserverPosition observer) async {
    await zhouTianModelManager.load();

    final engine = CalculationEngineFactory.create(config);
    final zhouTianModel = await engine.getSystemDefinition(config);
    uiZhouTianModelNotifier.value = zhouTianModel;
    final starPositions = await engine.calculateStarPositions(
        observer.dateTime, observer, config);
    final starAngleMapper = _transformStarPositions(starPositions, config);

    final panelService = GenerateBasePanelService(
      panelConfig: config,
      observerPosition: observer,
      shenShaManager: shenShaManager,
      huaYaoManager: huaYaoManager,
    );

    _basicLifePanel = await panelService.calculate(
      zhouTianModel: zhouTianModel,
      starAngleMapper: starAngleMapper,
    );

    // 实现 UI 星体计算逻辑
    if (_baseMiniSafetyAngle > 0) {
      _uiBasicLifeStars = _calculateUIStarsFromMapper(
        starAngleMapper,
        _baseMiniSafetyAngle,
      );
    } else {
      // 如果安全角度未设置,使用默认值10度
      _uiBasicLifeStars = _calculateUIStarsFromMapper(starAngleMapper, 10.0);
      debugPrint(
          "Warning: Using default safety angle (10.0) for UI stars calculation");
    }

    // 更新 ValueNotifier (UI兼容层)
    uiBasePanelNotifier.value = _basicLifePanel;
    uiBasicLifeStarsNotifier.value = _uiBasicLifeStars;

    notifyListeners();

    // 基础命盘计算完成后自动计算流年
    await calculateDaXian();
  }

  // ==================== UI兼容层: dispose ====================
  /// 释放资源
  /// 必须释放所有 ValueNotifier,否则会内存泄漏
  @override
  void dispose() {
    uiZhouTianModelNotifier.dispose();
    uiBasePanelNotifier.dispose();
    uiDaXianPanelNotifier.dispose();
    uiBasicLifeStarsNotifier.dispose();
    uiFateLifeStarsNotifier.dispose();
    baseObserverPositionNotifier.dispose();
    super.dispose();
  }

  // ==================== UI兼容层: 星体安全角度计算 ====================
  /// 计算本命盘 UI 绘制时星体所需的最小安全角度
  ///
  /// [starBodyRadius]: 星体图标的半径
  /// [starInnRangeMiddleSize]: 星宿范围中间的大小
  /// [basicLifeStarCenterCircleSize]: 本命盘中心圆的大小
  void calculateBasicStarsSafetyAngle(
    double starBodyRadius,
    double starInnRangeMiddleSize,
    double basicLifeStarCenterCircleSize,
  ) {
    _baseMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
      basicLifeStarCenterCircleSize,
      starInnRangeMiddleSize,
      starBodyRadius,
    );
    // 增加额外的填充以优化 UI 外观
    _baseMiniSafetyAngle =
        _baseMiniSafetyAngle.ceilToDouble() + _uiSafetyAnglePadding;
    debugPrint("Base Safety Angle Calculated: $_baseMiniSafetyAngle");
  }

  /// 计算大限盘 UI 绘制时星体所需的最小安全角度
  ///
  /// [starBodyRadius]: 星体图标的半径
  /// [starInnRangeMiddleSize]: 星宿范围中间的大小
  /// [fateStarCenterCircleSize]: 大限盘中心圆的大小
  void calculateFateStarsSafetyAngle(
    double starBodyRadius,
    double starInnRangeMiddleSize,
    double fateStarCenterCircleSize,
  ) {
    _fateMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
      fateStarCenterCircleSize,
      starInnRangeMiddleSize,
      starBodyRadius,
    );
    // 增加额外的填充以优化 UI 外观
    _fateMiniSafetyAngle =
        _fateMiniSafetyAngle.ceilToDouble() + _uiSafetyAnglePadding;
    debugPrint("Fate Safety Angle Calculated: $_fateMiniSafetyAngle");
  }

  // ==================== UI兼容层: 星体UI计算 ====================
  /// 将服务计算的结果转换为 UI 需要的格式
  ///
  /// [starsAngleMapper]: 星体到 StarAngleSpeed 信息的映射
  /// [miniSafetyAngle]: UI 绘制时星体所需的最小安全角度
  /// 返回: 适用于 UI 绘制的 UIStarModel 列表
  List<UIStarModel> _calculateUIStarsFromMapper(
    Map<EnumStars, StarAngleSpeed> starsAngleMapper,
    double miniSafetyAngle,
  ) {
    // 定义星体及其在 UI 调整位置时的优先级
    // 优先级越高,越不容易被移动
    List<UIStarModel> unadjustedStarList = [
      UIStarModel(
        star: EnumStars.Sun,
        originalAngle: starsAngleMapper[EnumStars.Sun]?.angle ?? 0,
        priority: 4, // 太阳优先级最高
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Moon,
        originalAngle: starsAngleMapper[EnumStars.Moon]?.angle ?? 0,
        priority: 3, // 月亮优先级次之
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Venus,
        originalAngle: starsAngleMapper[EnumStars.Venus]?.angle ?? 0,
        priority: 2, // 五星优先级中等
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Jupiter,
        originalAngle: starsAngleMapper[EnumStars.Jupiter]?.angle ?? 0,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mercury,
        originalAngle: starsAngleMapper[EnumStars.Mercury]?.angle ?? 0,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mars,
        originalAngle: starsAngleMapper[EnumStars.Mars]?.angle ?? 0,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Saturn,
        originalAngle: starsAngleMapper[EnumStars.Saturn]?.angle ?? 0,
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Qi, // 紫气
        originalAngle: starsAngleMapper[EnumStars.Qi]?.angle ?? 0,
        priority: 1, // 辅星优先级最低
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Bei, // 月孛
        originalAngle: starsAngleMapper[EnumStars.Bei]?.angle ?? 0,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Luo, // 罗睺
        originalAngle: starsAngleMapper[EnumStars.Luo]?.angle ?? 0,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Ji, // 计都
        originalAngle: starsAngleMapper[EnumStars.Ji]?.angle ?? 0,
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
    ];

    // 移除角度为0的星体 (可能表示该星体未计算或不存在于mapper中)
    unadjustedStarList.removeWhere(
      (starModel) =>
          starModel.originalAngle == 0 &&
          starsAngleMapper[starModel.star] == null,
    );

    // 使用 StarsResolver 计算调整后的 UI 位置
    return StarsResolver.resolveUIStars(unadjustedStarList);
  }

  Map<EnumStars, StarAngleSpeed> _transformStarPositions(
      List<StarPositionRawData> starPositions, BasePanelConfig config) {
    final Map<EnumStars, StarAngleSpeed> mapper = {};
    for (final pos in starPositions) {
      // Find the angle/speed info that matches the current panel configuration
      final matchingInfo = pos.angleRawInfoSet.firstWhere(
        (info) =>
            info.panelSystemType == config.panelSystemType &&
            info.coordinateSystem == config.celestialCoordinateSystem,
        orElse: () => pos.angleRawInfoSet
            .first, // Fallback to the first available if no exact match
      );
      mapper[pos.starType] = StarAngleSpeed(
        angle: matchingInfo.angle,
        speed: matchingInfo.speed,
      );
    }
    return mapper;
  }

  // ==================== 流年计算方法 ====================

  /// 计算流年星盘
  /// [fateDatetime]: 流年时间点，默认为当前时间
  Future<void> calculateDaXian([DateTime? fateDatetime]) async {
    final targetDateTime = fateDatetime ?? DateTime.now();

    // 确保基础命盘已计算
    if (_basicLifePanel == null || _lifeObserver == null) {
      debugPrint(
          "Warning: Cannot calculate fate panel without basic life panel");
      return;
    }

    // 生成流年观察者位置
    _fateObserver =
        _generateFateObserverPosition(targetDateTime, _lifeObserver!);

    try {
      // 调用流年计算服务
      final panelService = GenerateBasePanelService(
        panelConfig: _buildDefaultConfig(_lifeObserver!),
        observerPosition: _lifeObserver!,
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
      );

      // 重新计算流年星体位置
      final config = _buildDefaultConfig(_lifeObserver!);
      final engine = CalculationEngineFactory.create(config);
      final zhouTianModel = await engine.getSystemDefinition(config);
      final starPositions = await engine.calculateStarPositions(
          _fateObserver!.dateTime, _fateObserver!, config);
      final starAngleMapper = _transformStarPositions(starPositions, config);

      // 计算流年盘
      final passageYearPanel = await panelService.calculateDaXia(
        _basicLifePanel!,
        _fateObserver!,
        zhouTianModel: zhouTianModel,
        starAngleMapper: starAngleMapper,
      );

      // 计算流年星体UI数据
      _uiFateLifeStars = _calculateUIStarsFromMapper(
        starAngleMapper,
        _fateMiniSafetyAngle > 0 ? _fateMiniSafetyAngle : 10.0,
      );

      // 更新UI
      uiDaXianPanelNotifier.value = passageYearPanel;
      uiFateLifeStarsNotifier.value = _uiFateLifeStars;

      debugPrint("Fate panel calculated successfully for $targetDateTime");
      debugPrint("Fate stars count: ${_uiFateLifeStars.length}");
    } catch (e) {
      debugPrint("Error calculating fate panel: $e");
      _uiFateLifeStars = [];
      uiDaXianPanelNotifier.value = null;
      uiFateLifeStarsNotifier.value = null;
    }

    notifyListeners();
  }

  /// 生成流年观察者位置
  /// [fateDatetime]: 流年时间点
  /// [baseObserver]: 基础命盘的观察者位置
  ObserverPosition _generateFateObserverPosition(
      DateTime fateDatetime, ObserverPosition baseObserver) {
    // 将流年时间转换为与基础观察者相同的时区
    final tzDatetime =
        tz.TZDateTime.from(fateDatetime, tz.getLocation(baseObserver.timezone));

    // 计算流年干支
    final yearGanZhi = _calculateYearGanZhi(tzDatetime);
    final monthGanZhi = _calculateMonthGanZhi(tzDatetime);
    final dayGanZhi = _calculateDayGanZhi(tzDatetime);
    final timeGanZhi = _calculateTimeGanZhi(tzDatetime);

    // 判断是否日生
    final isDayBirth = _getDayTimeZhi().contains(timeGanZhi.zhi);

    return ObserverPosition(
      latitude: baseObserver.latitude,
      longitude: baseObserver.longitude,
      altitude: baseObserver.altitude,
      timezone: baseObserver.timezone,
      dateTime: tzDatetime,
      isDayBirth: isDayBirth,
      yearGanZhi: yearGanZhi,
      monthGanZhi: monthGanZhi,
      dayGanZhi: dayGanZhi,
      timeGanZhi: timeGanZhi,
    );
  }

  /// 计算年份干支（简化版本，实际应使用完整干支计算）
  JiaZi _calculateYearGanZhi(tz.TZDateTime datetime) {
    // 这里应该使用完整的干支计算逻辑
    // 为简化，返回基础命盘的年份干支
    return _lifeObserver!.yearGanZhi;
  }

  /// 计算月份干支（简化版本）
  JiaZi _calculateMonthGanZhi(tz.TZDateTime datetime) {
    // 这里应该使用完整的干支计算逻辑
    // 为简化，返回基础命盘的月份干支
    return _lifeObserver!.monthGanZhi;
  }

  /// 计算日干支（简化版本）
  JiaZi _calculateDayGanZhi(tz.TZDateTime datetime) {
    // 这里应该使用完整的干支计算逻辑
    // 为简化，返回基础命盘的日干支
    return _lifeObserver!.dayGanZhi;
  }

  /// 计算时辰干支（简化版本）
  JiaZi _calculateTimeGanZhi(tz.TZDateTime datetime) {
    // 这里应该使用完整的干支计算逻辑
    // 为简化，返回基础命盘的时辰干支
    return _lifeObserver!.timeGanZhi;
  }
}
