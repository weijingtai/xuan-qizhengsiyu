import 'package:metaphysics_core/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_input_builder.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/services/generate_base_panel_service.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_evaluation_service.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/rise_set_display_data.dart';
import 'package:metaphysics_core/utils/celestial_rise_set_calculator.dart';
import 'package:metaphysics_core/helpers/solar_time_calculator.dart';
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
import 'package:metaphysics_core/adapters/lunar_adapter.dart';
import 'package:metaphysics_core/models/lunar_date_info_v2_data.dart';
import 'package:metaphysics_core/enums/datetime_strategy_enums.dart';
import 'package:metaphysics_core/features/datetime_details/datetime_details_bundle_calculation.dart';
import 'package:xuan_common/features/liu_yun/viewmodels/yun_liu_view_model.dart';
import 'package:xuan_common/features/liu_yun/services/yun_liu_service.dart';
import 'package:metaphysics_core/helpers/solar_lunar_datetime_helper.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/datamodel/location.dart' as loc;
import 'dart:math';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart'
    as UIPanelConfig; // UI层的PanelConfig
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/models/divination_info_model.dart';
import 'package:metaphysics_core/models/shen_sha.dart'; // DivinationInfoModel
import 'package:metaphysics_core/datamodel/datetime_divination_datamodel.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums.dart';
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
  final GeJuEvaluationService? geJuEvaluationService;

  QiZhengSiYuViewModel({
    required this.shenShaManager,
    required this.huaYaoManager,
    required this.zhouTianModelManager,
    this.geJuEvaluationService,
  });

  // ==================== 核心状态 (MVVM) ====================
  BasePanelModel? _basicLifePanel;
  BasePanelModel? get basicLifePanel => _basicLifePanel;

  /// 出生年甲子（格局评估使用）
  JiaZi? _birthYearJiaZi;

  /// 出生月地支（格局评估使用）
  DiZhi? _birthMonthZhi;

  /// 出生日期时间（月相计算使用）
  DateTime? _birthDateTime;

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

  /// 格局评估结果 - 用于 ValueListenableBuilder
  final ValueNotifier<GeJuEvaluationSummary?> geJuSummaryNotifier =
      ValueNotifier(null);

  /// 出生时日月出没信息
  final ValueNotifier<RiseSetDisplayData?> birthRiseSetNotifier =
      ValueNotifier(null);

  /// 自定义日期日月出没信息
  final ValueNotifier<RiseSetDisplayData?> customRiseSetNotifier =
      ValueNotifier(null);

  // ==================== LunarDateInfo + YunLiu ====================
  /// 时间详情数据 - 用于 LunarDateInfoCardV2
  final ValueNotifier<LunarDateInfoV2Data?> lunarDateInfoNotifier =
      ValueNotifier(null);

  /// 大运流年 ViewModel - 用于 YunLiuListTileCardWidget
  YunLiuViewModel? _yunLiuViewModel;
  YunLiuViewModel? get yunLiuViewModel => _yunLiuViewModel;

  /// 出生地地址信息（用于显示地名）
  String? _birthLocationName;
  String? get birthLocationName => _birthLocationName;

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

    // 提取地址名称用于日月出没面板显示
    final datetimeData = divinationInfoModel.divinationDatetime;
    final datetimeModel = datetimeData.timingInfoListJson!
        .firstWhere((t) => t.uuid == datetimeData.timingInfoUuid);
    final address = datetimeModel.observer.location?.address;
    if (address != null) {
      final parts = <String>[];
      if (address.city != null) parts.add(address.city!.name);
      parts.add('${address.countryName} ${address.province.name}');
      _birthLocationName = parts.join(', ');
    }
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

    // 保存出生时间参数（格局评估使用）
    _birthYearJiaZi = observer.yearGanZhi;
    _birthMonthZhi = observer.monthGanZhi.zhi;
    _birthDateTime = observer.dateTime;

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

    // 计算出生时日月出没信息
    birthRiseSetNotifier.value = _computeRiseSetData(_lifeObserver!);

    notifyListeners();

    // 基础命盘计算完成后自动计算流年
    await calculateDaXian();

    // 基础命盘计算完成后自动评估格局
    evaluateGeJu(onlyMatched: true);

    // 基础命盘计算完成后构建时间详情和大运流年
    await buildLunarDateInfo();
    buildYunLiuViewModel();
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
    geJuSummaryNotifier.dispose();
    birthRiseSetNotifier.dispose();
    customRiseSetNotifier.dispose();
    lunarDateInfoNotifier.dispose();
    _yunLiuViewModel?.dispose();
    super.dispose();
  }

  // ==================== LunarDateInfo + YunLiu 构建 ====================

  /// 构建时间详情数据 (用于 LunarDateInfoCardV2)
  Future<void> buildLunarDateInfo() async {
    if (_lifeObserver == null) return;

    final observer = _lifeObserver!;
    final params = DateTimeDetailsCalculationParams(
      inputDateTime: observer.dateTime,
      timezoneStr: observer.timezone,
      coordinates: loc.Coordinates(
        latitude: observer.latitude,
        longitude: observer.longitude,
      ),
    );

    try {
      final bundle = await DateTimeDetailsBundleCalculation.calculate(
        params: params,
      );
      lunarDateInfoNotifier.value = LunarDateInfoV2Data(
        bundle: bundle,
        inUsed: EnumDatetimeType.standard,
      );
    } catch (e) {
      debugPrint('[LunarDateInfo] calculation error: $e');
    }
  }

  /// 构建大运流年 ViewModel (用于 YunLiuListTileCardWidget)
  void buildYunLiuViewModel() {
    if (_lifeObserver == null) return;

    final observer = _lifeObserver!;
    final birthDateInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      observer.dateTime,
      ZiShiStrategy.noDistinguishAt23,
    );

    _yunLiuViewModel?.dispose();
    _yunLiuViewModel = YunLiuViewModel(
      service: YunLiuService(),
      birthDateTime: observer.dateTime,
      gender: Gender.male, // TODO: 从占卜上下文获取性别
      birthDateInfo: birthDateInfo,
    );
    notifyListeners();
  }

  // ==================== 格局评估 ====================

  /// 使格局规则数据缓存失效（用户增删改规则后调用）
  void invalidateGeJuCache() {
    geJuEvaluationService?.invalidateRuleDataCache();
  }

  /// 当前是否启用预过滤器
  bool get geJuUsePreFilter => geJuEvaluationService?.usePreFilter ?? true;

  /// 切换预过滤器开关并重新评估（debug 用）
  Future<void> toggleGeJuPreFilter() async {
    final svc = geJuEvaluationService;
    if (svc == null) return;
    svc.usePreFilter = !svc.usePreFilter;
    await evaluateGeJu(onlyMatched: true);
  }

  /// 评估当前命盘的格局
  ///
  /// 结果通过 [geJuSummaryNotifier] 通知，同时作为返回值。
  /// [onlyMatched] 为 true 时只返回匹配格局，默认 false 返回全部。
  Future<GeJuEvaluationSummary?> evaluateGeJu({
    bool onlyMatched = false,
    Set<String> preferredSchools = const {'guo_lao'},
  }) async {
    if (geJuEvaluationService == null) {
      debugPrint('GeJuEvaluationService not injected');
      return null;
    }
    final panel = _basicLifePanel;
    final monthZhi = _birthMonthZhi;
    final yearJiaZi = _birthYearJiaZi;
    if (panel == null || monthZhi == null || yearJiaZi == null) {
      debugPrint('evaluateGeJu: panel not calculated yet');
      return null;
    }

    final starsSet = GeJuInputBuilder.buildElevenStarsSetFromPanel(
      panel,
      birthDateTime: _birthDateTime,
    );
    final summary = await geJuEvaluationService!.evaluateNatalChart(
      panelModel: panel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      preferredSchools: preferredSchools,
      onlyMatched: onlyMatched,
    );

    geJuSummaryNotifier.value = summary;
    notifyListeners();
    return summary;
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
    // 映射到 UI 视觉空间 (始终为 360 度)
    // 根据设计原则: visualDegree = (projected / totalDegree) * 360
    double normalize(double? projected) {
      if (projected == null) return 0;
      return (projected / _zhouTianModel!.totalDegree) * 360.0;
    }

    List<UIStarModel> unadjustedStarList = [
      UIStarModel(
        star: EnumStars.Sun,
        originalAngle: normalize(starsAngleMapper[EnumStars.Sun]?.angle),
        priority: 4, // 太阳优先级最高
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Moon,
        originalAngle: normalize(starsAngleMapper[EnumStars.Moon]?.angle),
        priority: 3, // 月亮优先级次之
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Venus,
        originalAngle: normalize(starsAngleMapper[EnumStars.Venus]?.angle),
        priority: 2, // 五星优先级中等
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Jupiter,
        originalAngle: normalize(starsAngleMapper[EnumStars.Jupiter]?.angle),
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mercury,
        originalAngle: normalize(starsAngleMapper[EnumStars.Mercury]?.angle),
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Mars,
        originalAngle: normalize(starsAngleMapper[EnumStars.Mars]?.angle),
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Saturn,
        originalAngle: normalize(starsAngleMapper[EnumStars.Saturn]?.angle),
        priority: 2,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Qi, // 紫气
        originalAngle: normalize(starsAngleMapper[EnumStars.Qi]?.angle),
        priority: 1, // 辅星优先级最低
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Bei, // 月孛
        originalAngle: normalize(starsAngleMapper[EnumStars.Bei]?.angle),
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Luo, // 罗睺
        originalAngle: normalize(starsAngleMapper[EnumStars.Luo]?.angle),
        priority: 1,
        rangeAngleEachSide: miniSafetyAngle,
      ),
      UIStarModel(
        star: EnumStars.Ji, // 计都
        originalAngle: normalize(starsAngleMapper[EnumStars.Ji]?.angle),
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

  // ==================== 日月出没计算 ====================

  /// 计算日月出没展示数据
  RiseSetDisplayData? _computeRiseSetData(ObserverPosition observer) {
    try {
      // 日月出没（UTC）
      final dailyInfo = CelestialRiseSetCalculator.calculateDaily(
        utcDateTime: observer.utcDateTime,
        longitude: observer.longitude,
        latitude: observer.latitude,
        altitude: observer.altitude,
      );

      // UTC → 本地时区
      final loc = tz.getLocation(observer.timezone);
      DateTime? toLocal(DateTime? utc) =>
          utc != null ? tz.TZDateTime.from(utc, loc) : null;

      // 真太阳时
      final trueSolarTime = SolarTimeCalculator(
        dateTime: observer.utcDateTime,
        longitude: observer.longitude,
      ).getTrueSolarTime();

      // 阴历信息（基于本地时间）
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
        locationName: _birthLocationName,
        jieQiInfo: jieQiInfo,
      );
    } catch (e) {
      debugPrint('Error computing rise/set data: $e');
      return null;
    }
  }

  /// 更新自定义日期的日月出没数据（供 UI 日期选择器调用）
  void updateCustomDate(DateTime selectedDate) {
    if (_lifeObserver == null) return;

    final loc = tz.getLocation(_lifeObserver!.timezone);
    final tzDateTime = tz.TZDateTime(
        loc, selectedDate.year, selectedDate.month, selectedDate.day, 12, 0);

    final yearGanZhi = _calculateYearGanZhi(tzDateTime);
    final monthGanZhi = _calculateMonthGanZhi(tzDateTime);
    final dayGanZhi = _calculateDayGanZhi(tzDateTime);
    final timeGanZhi = _calculateTimeGanZhi(tzDateTime);

    final customObserver = ObserverPosition(
      latitude: _lifeObserver!.latitude,
      longitude: _lifeObserver!.longitude,
      altitude: _lifeObserver!.altitude,
      timezone: _lifeObserver!.timezone,
      dateTime: tzDateTime,
      isDayBirth: _getDayTimeZhi().contains(timeGanZhi.zhi),
      yearGanZhi: yearGanZhi,
      monthGanZhi: monthGanZhi,
      dayGanZhi: dayGanZhi,
      timeGanZhi: timeGanZhi,
    );

    customRiseSetNotifier.value = _computeRiseSetData(customObserver);
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
      debugPrint("[DaXian] Step 1: Creating panel service...");
      final panelService = GenerateBasePanelService(
        panelConfig: _buildDefaultConfig(_lifeObserver!),
        observerPosition: _lifeObserver!,
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
      );

      // 重新计算流年星体位置
      debugPrint("[DaXian] Step 2: Building config & engine...");
      final config = _buildDefaultConfig(_lifeObserver!);
      final engine = CalculationEngineFactory.create(config);

      debugPrint("[DaXian] Step 3: Getting system definition...");
      final zhouTianModel = await engine.getSystemDefinition(config);

      debugPrint("[DaXian] Step 4: Calculating star positions for $targetDateTime...");
      final starPositions = await engine.calculateStarPositions(
          _fateObserver!.dateTime, _fateObserver!, config);

      debugPrint("[DaXian] Step 5: Transforming star positions...");
      final starAngleMapper = _transformStarPositions(starPositions, config);

      // 计算流年盘
      debugPrint("[DaXian] Step 6: Calculating DaXia panel...");
      final passageYearPanel = await panelService.calculateDaXia(
        _basicLifePanel!,
        _fateObserver!,
        zhouTianModel: zhouTianModel,
        starAngleMapper: starAngleMapper,
      );

      debugPrint("[DaXian] Step 7: Success! huaYaoMapper entries: ${passageYearPanel.huaYaoMapper.length}");

      // 计算流年星体UI数据
      _uiFateLifeStars = _calculateUIStarsFromMapper(
        starAngleMapper,
        _fateMiniSafetyAngle > 0 ? _fateMiniSafetyAngle : 10.0,
      );

      // 更新UI
      uiDaXianPanelNotifier.value = passageYearPanel;
      uiFateLifeStarsNotifier.value = _uiFateLifeStars;

      // 计算流年日月出没信息
      customRiseSetNotifier.value = _computeRiseSetData(_fateObserver!);

      debugPrint("Fate panel calculated successfully for $targetDateTime");
      debugPrint("Fate stars count: ${_uiFateLifeStars.length}");
    } catch (e, stackTrace) {
      debugPrint("Error calculating fate panel: $e");
      debugPrint("Stack trace: $stackTrace");
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

  /// 计算年份干支
  JiaZi _calculateYearGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getYearInGanZhi())!;
  }

  /// 计算月份干支
  JiaZi _calculateMonthGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getMonthInGanZhi())!;
  }

  /// 计算日干支
  JiaZi _calculateDayGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
  }

  /// 计算时辰干支
  JiaZi _calculateTimeGanZhi(tz.TZDateTime datetime) {
    final lunar = LunarAdapter.fromDate(datetime);
    return JiaZi.getFromGanZhiValue(lunar.getTimeInGanZhi())!;
  }
}
