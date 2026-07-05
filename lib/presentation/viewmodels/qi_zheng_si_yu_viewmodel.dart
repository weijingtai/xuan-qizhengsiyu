import 'package:metaphysics_core/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/rise_set_display_data.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/pages/StarsResolver.dart';
import 'package:qizhengsiyu/presentation/models/lunar_date_info_v2_data.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:metaphysics_core/enums/datetime_strategy_enums.dart';
import 'package:metaphysics_core/models/calculation_strategy_config_logic_model.dart';
import 'package:metaphysics_core/helpers/solar_lunar_datetime_helper.dart';
import 'package:metaphysics_core/domain/calculators/liu_yun/services/yun_liu_service.dart';
import 'package:metaphysics_core/utils/celestial_rise_set_calculator.dart';
import 'package:metaphysics_core/helpers/solar_time_calculator.dart';
import 'package:metaphysics_core/adapters/lunar_adapter.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/divination_info_model.dart';
import 'package:metaphysics_core/datamodel/datetime_divination_datamodel.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:calendar/calendar.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart' as ui_panel_config;
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart';

/// 七政四余 ViewModel - MVVM架构 + UI兼容层
///
/// 本ViewModel通过UseCase持有业务逻辑,提供与旧UI层兼容的接口。
/// - 核心架构: 注入UseCase,不直接依赖 domain managers/engines
/// - UI兼容层: 提供 ValueNotifier 和兼容方法,确保现有UI无需大改
class QiZhengSiYuViewModel extends ChangeNotifier {
  // ==================== 核心依赖 (UseCase层) ====================
  final InitializeQiZhengOfficialDataUseCase _initUseCase;
  final CalculateQiZhengBasePanelUseCase _calculateUseCase;
  final EvaluateQiZhengGeJuUseCase _evaluateGeJuUseCase;
  final BuildQiZhengTimelineUseCase _buildTimelineUseCase;

  QiZhengSiYuViewModel({
    required InitializeQiZhengOfficialDataUseCase initializeOfficialDataUseCase,
    required CalculateQiZhengBasePanelUseCase calculateBasePanelUseCase,
    required EvaluateQiZhengGeJuUseCase evaluateGeJuUseCase,
    required BuildQiZhengTimelineUseCase buildTimelineUseCase,
  })  : _initUseCase = initializeOfficialDataUseCase,
        _calculateUseCase = calculateBasePanelUseCase,
        _evaluateGeJuUseCase = evaluateGeJuUseCase,
        _buildTimelineUseCase = buildTimelineUseCase;

  // ==================== 核心状态 (MVVM) ====================
  BasePanelModel? _basicLifePanel;
  BasePanelModel? get basicLifePanel => _basicLifePanel;

  /// 出生年甲子（格局评估使用）
  JiaZi? _birthYearJiaZi;

  /// 出生月地支（格局评估使用）
  DiZhi? _birthMonthZhi;

  /// 最后计算出的星体角度映射
  Map<EnumStars, StarAngleSpeed>? _lastStarAngleMapper;

  List<UIStarModel> _uiBasicLifeStars = [];
  List<UIStarModel> get uiBasicLifeStars => _uiBasicLifeStars;

  ZhouTianModel? _zhouTianModel;

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

  // ==================== UI兼容层: 私有状态 ====================
  /// 本命盘星体的最小安全角度
  double _baseMiniSafetyAngle = 0.0;

  /// 大限盘星体的最小安全角度
  double _fateMiniSafetyAngle = 0.0;

  /// UI层覆盖配置 (用于路由参数传入的配置)
  ui_panel_config.PanelConfig? _overridePanelConfig;

  // ==================== UI兼容层: 初始化方法 ====================
  /// 初始化 ViewModel
  /// 通过 UseCase 加载官方数据
  Future<void> init() async {
    await _initUseCase.execute();
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
  List<DiZhi> _getDayTimeZhi() {
    return [DiZhi.YIN, DiZhi.MAO, DiZhi.CHEN, DiZhi.SI, DiZhi.WU, DiZhi.WEI, DiZhi.SHEN, DiZhi.YOU];
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
  void setOverridePanelConfig(ui_panel_config.PanelConfig config) {
    _overridePanelConfig = config;
  }

  /// 将UI层的PanelConfig转换为domain层的BasePanelConfig
  BasePanelConfig _convertUIPanelConfigToBasePanelConfig(
      ui_panel_config.PanelConfig uiConfig) {
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
  /// 通过 UseCase 执行星盘计算、时间线构建、格局评估
  Future<void> calculateWithConfig(
      BasePanelConfig config, ObserverPosition observer) async {
    await _initUseCase.execute();

    final panelResult = await _calculateUseCase.execute(
      config: config,
      observer: observer,
    );

    _basicLifePanel = panelResult.basicLifePanel;
    _zhouTianModel = panelResult.zhouTianModel;
    _lastStarAngleMapper = panelResult.starAngleMapper;

    // 保存出生时间参数（格局评估使用）
    _birthYearJiaZi = observer.yearGanZhi;
    _birthMonthZhi = observer.monthGanZhi.zhi;

    // 构建 UI 星体
    if (_baseMiniSafetyAngle > 0) {
      _uiBasicLifeStars = _calculateUIStarsFromMapper(_lastStarAngleMapper!, _baseMiniSafetyAngle);
    } else {
      _uiBasicLifeStars = _calculateUIStarsFromMapper(_lastStarAngleMapper!, 10.0);
    }

    uiZhouTianModelNotifier.value = _zhouTianModel;
    uiBasePanelNotifier.value = _basicLifePanel;
    uiBasicLifeStarsNotifier.value = _uiBasicLifeStars;

    // 出生时日月出没信息
    birthRiseSetNotifier.value = _computeRiseSetData(_lifeObserver!);

    notifyListeners();

    // 构建时间线和流年数据
    final timelineResult = await _buildTimelineUseCase.execute(
      lifeObserver: observer,
      basicLifePanel: _basicLifePanel!,
      locationName: _birthLocationName,
    );

    // Lunar date info 由 buildLunarDateInfo 或 YunLiu path 处理

    // DaXian（如果有 fateObserver 数据）
    if (timelineResult.passageYearPanel != null) {
      uiDaXianPanelNotifier.value = timelineResult.passageYearPanel;
      if (timelineResult.fateStarAngleMapper != null) {
        _uiFateLifeStars = _calculateUIStarsFromMapper(timelineResult.fateStarAngleMapper!, 10.0);
        uiFateLifeStarsNotifier.value = _uiFateLifeStars;
        _daXianMapper = null; // 重建
      }
    }

    // 构建 YunLiu ViewModel
    buildYunLiuViewModel();

    // 格局评估
    _birthYearJiaZi = observer.yearGanZhi;
    _birthMonthZhi = observer.monthGanZhi.zhi;
    await evaluateGeJu(onlyMatched: true);
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

  /// 构建大运流年 ViewModel (用于 YunLiuListTileCardWidget)
  void buildYunLiuViewModel() {
    if (_lifeObserver == null) return;

    final observer = _lifeObserver!;
    final birthDateInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfoV2(
      observer.dateTime,
      CalculationStrategyConfigLogicModel.defaultConfig.copyWith(
        ziStrategy: ZiShiStrategy.noDistinguishAt23,
      ),
    );

    _yunLiuViewModel?.dispose();
    _yunLiuViewModel = YunLiuViewModel(
      service: YunLiuService(),
      birthDateTime: observer.dateTime,
      gender: Gender.male,
      birthDateInfo: birthDateInfo,
    );
    notifyListeners();
  }

  // ==================== 格局评估 ====================

  /// 使格局规则数据缓存失效
  void invalidateGeJuCache() {
    _evaluateGeJuUseCase.invalidateCache();
  }

  /// 当前是否启用预过滤器
  bool get geJuUsePreFilter => _evaluateGeJuUseCase.usePreFilter;

  /// 切换预过滤器
  Future<void> toggleGeJuPreFilter() async {
    _evaluateGeJuUseCase.usePreFilter = !_evaluateGeJuUseCase.usePreFilter;
    await evaluateGeJu(onlyMatched: true);
  }

  /// 评估当前命盘格局
  Future<GeJuEvaluationSummary?> evaluateGeJu({
    bool onlyMatched = false,
    Set<String> preferredSchools = const {'guo_lao'},
  }) async {
    final panel = _basicLifePanel;
    final monthZhi = _birthMonthZhi;
    final yearJiaZi = _birthYearJiaZi;
    if (panel == null || monthZhi == null || yearJiaZi == null) {
      debugPrint('evaluateGeJu: panel not calculated yet');
      return null;
    }

    final starsSet = _buildElevenStarsSetFromPanel(panel);

    final summary = await _evaluateGeJuUseCase.execute(
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

  Set<ElevenStarsInfo> _buildElevenStarsSetFromPanel(BasePanelModel panel) {
    final set = <ElevenStarsInfo>{};
    for (final entry in panel.enteredGongMapper.entries) {
      final angleSpeed = _lastStarAngleMapper?[entry.key];
      set.add(ElevenStarsInfo(
        star: entry.key,
        angle: angleSpeed?.angle ?? 0.0,
        enterInfo: entry.value,
        fiveStarWalkingType: FiveStarWalkingType.Normal,
        walkingSpeed: angleSpeed?.speed ?? 0.0,
        priority: EnumStarsPriority.Normal,
      ));
    }
    return set;
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
      return (projected / uiZhouTianModelNotifier.value!.totalDegree) * 360.0;
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
  Future<void> calculateDaXian([DateTime? fateDatetime]) async {
    final targetDateTime = fateDatetime ?? DateTime.now();

    if (_basicLifePanel == null || _lifeObserver == null) {
      debugPrint("Warning: Cannot calculate fate panel without basic life panel");
      return;
    }

    _fateObserver = _generateFateObserverPosition(targetDateTime, _lifeObserver!);

    try {
      final result = await _buildTimelineUseCase.execute(
        lifeObserver: _lifeObserver!,
        basicLifePanel: _basicLifePanel!,
        fateObserver: _fateObserver!,
        locationName: _birthLocationName,
      );

      if (result.passageYearPanel != null) {
        uiDaXianPanelNotifier.value = result.passageYearPanel;
        if (result.fateStarAngleMapper != null) {
          _uiFateLifeStars = _calculateUIStarsFromMapper(
            result.fateStarAngleMapper!,
            _fateMiniSafetyAngle > 0 ? _fateMiniSafetyAngle : 10.0,
          );
          uiFateLifeStarsNotifier.value = _uiFateLifeStars;
        }
        customRiseSetNotifier.value = _computeRiseSetData(_fateObserver!);
      }
      debugPrint("Fate panel calculated successfully for $targetDateTime");
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
