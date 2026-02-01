import 'dart:convert';
import 'dart:math';

import 'package:common/datamodel/datetime_divination_datamodel.dart';
import 'package:common/datamodel/location.dart';
import 'package:common/datamodel/observer_datamodel.dart';
import 'package:common/enums.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/module.dart';
import 'package:flutter/foundation.dart'; // 使用 @visibleForTesting
import 'package:flutter/material.dart'; // ChangeNotifier 仍然需要
import 'package:flutter/services.dart';
import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';
import 'package:qizhengsiyu/data/repositories/hua_yao_repository_impl.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/v7.dart';

import '../../data/datasources/local/shen_sha_local_data_source.dart';
import '../../data/repositories/shen_sha_repository_impl.dart';
import '../../domain/entities/models/base_panel_model.dart';
import '../../domain/entities/models/body_life_model.dart';
import '../../domain/entities/models/observer_position.dart';
import '../../domain/entities/models/panel_config.dart';
import '../../domain/entities/models/passage_year_panel_model.dart';
import '../../domain/entities/models/star_angle_speed.dart';
import '../../domain/entities/models/stars_angle.dart';
import '../../domain/managers/hua_yao_manager.dart';
import '../../domain/managers/shen_sha_manager.dart';
import '../../domain/managers/zhou_tian_model_manager.dart';
import '../../domain/services/generate_base_panel_service.dart';
import '../../domain/usecases/calculate_fate_dong_wei_usecase.dart';
import '../../domain/usecases/save_calculated_panel_usecase.dart';
import '../models/ui_star_model.dart';
import '../../domain/engines/calculation_engine_factory.dart';
import '../../domain/entities/models/zhou_tian_model.dart';
import 'StarsResolver.dart';

/// 七政四余星盘计算和数据管理的 ViewModel。
/// 负责加载必要数据、根据观测位置和时间计算星体位置，
/// 生成星盘详细信息和 UI 显示数据，并管理状态通知 UI 更新。
class BeautyPageViewModel extends ChangeNotifier {
  // MARK: - Constants

  /// UI安全角度额外增加的度数，用于避免星体图标重叠。
  static const double _uiSafetyAnglePadding = 2.0;
  // static DivinationDatetimeModel? divinationDatetimeModel;
  ObserverDataModel? observer;

  /// 紫气计算的基准时间点 (上海时区)。
  /// 此计算方法基于特定术数规则，非标准天文计算。
  static final tz.TZDateTime _ziQiBaseShangHaiTime =
      tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
  late final SaveCalculatedPanelUseCase saveCalculatedPanelUseCase;
  late final CalculateFateDongWeiUseCase calculateFateDongWeiUseCase;

  /// 紫气每日运行角度 (度)。
  /// 每24小时运行 02′07″，约等于 0.0352 度。
  static const double _ziQiAnglePerDay = 0.0352;

  /// 紫气每分钟运行角度 (度)。
  static const double _ziQiAnglePerMinute = _ziQiAnglePerDay / (24 * 60);

  // MARK: - Star Data

  // MARK: - UI Data

  /// 本命盘用于 UI 显示的星体列表，已调整位置避免重叠。
  List<UIStarModel> _uiBasicLifeStars = [];
  List<UIStarModel> get uiBasicLifeStars => _uiBasicLifeStars;

  final ValueNotifier<List<UIStarModel>?> uiBasicLifeStarsNotifier =
      ValueNotifier<List<UIStarModel>?>(null);

  final ValueNotifier<BasePanelModel?> uiBasePanelNotifier =
      ValueNotifier<BasePanelModel?>(null);
  final ValueNotifier<PassageYearPanelModel?> uiDaXianPanelNotifier =
      ValueNotifier<PassageYearPanelModel?>(null);

  final ValueNotifier<ObserverPosition?> baseObserverPositionNotifier =
      ValueNotifier<ObserverPosition?>(null);

  final ValueNotifier<CalculateFateDongWeiResult?> dongWeiFateResultNotifier =
      ValueNotifier(null);

  /// 行限盘（或起盘）用于 UI 显示的星体列表，已调整位置避免重叠。
  List<UIStarModel> _uiFateLifeStars = [];
  List<UIStarModel> get uiFateLifeStars => _uiFateLifeStars;

  final ValueNotifier<List<UIStarModel>?> uiFateLifeStarsNotifier =
      ValueNotifier<List<UIStarModel>?>(null);
  // MARK: - Panel Information

  /// 五星大限运行信息映射。
  Map<EnumStars, FiveStarWalkingInfo>? _daXianMapper;
  Map<EnumStars, FiveStarWalkingInfo>? get daXianMapper => _daXianMapper;

  // ValueNotifier<Map<EnumTwelveGong, List<ShenSha>>?> gongShenShaNotifier =
  // ValueNotifier<Map<EnumTwelveGong, List<ShenSha>>?>(null);

  // MARK: - Configuration and Managers

  /// UI 绘制本命盘时星体所需的最小安全角度。
  double _baseMiniSafetyAngle = 5;

  /// UI 绘制行限盘时星体所需的最小安全角度。
  double _fateMiniSafetyAngle = 7;

  /// 神煞数据管理器。
  ShenShaManager? _shenShaManager;
  ShenShaManager get shenShaManager {
    // 提供一个默认值或抛出错误，如果在使用前未初始化
    if (_shenShaManager == null) {
      // 应该在init()中初始化
      throw StateError('ShenShaManager not initialized. Call init() first.');
    }
    return _shenShaManager!;
  }

  ZhouTianModelManager get zhouTianModelManager =>
      ZhouTianModelManager.instance;

  /// 化曜数据管理器。
  HuaYaoManager? _huaYaoManager;
  HuaYaoManager get huaYaoManager {
    // 提供一个默认值或抛出错误，如果在使用前未初始化
    if (_huaYaoManager == null) {
      // 应该在init()中初始化
      throw StateError('HuaYaoManager not initialized. Call init() first.');
    }
    return _huaYaoManager!;
  }

  // MARK: - Services

  /// 生成基础星盘数据的服务。
  /// 使用 late 关键字表示在使用前会被初始化，通常在 calculate 方法中。
  late final GenerateBasePanelService _generateBasePanelService;

  // MARK: - Constructor

  /// QiZhengSiYuViewModel 构造函数。
  /// 注意: 移除了 BuildContext 参数，ViewModel 不应持有 UI Context。
  BeautyPageViewModel(
      {required this.saveCalculatedPanelUseCase,
      required this.calculateFateDongWeiUseCase});

  // MARK: - Initialization

  /// 异步初始化 ViewModel，加载神煞和化曜数据。
  Future<void> init() async {
    try {
      final result = await Future.wait([
        _loadShenShaManager(),
        _loadHuaYaoManager(),
        ZhouTianModelManager.instance.load(), // 添加周天模型加载
      ]);
      _shenShaManager = result[0] as ShenShaManager;
      _huaYaoManager = result[1] as HuaYaoManager;
      // 第三个结果是 void，不需要赋值
      // 初始化服务，因为它依赖于 Manager
      debugPrint("ViewModel init complete: Managers loaded.");
    } catch (e) {
      debugPrint("Error initializing ViewModel: $e");
      // 根据需要处理错误，例如显示一个错误消息
      rethrow; // 重新抛出错误以便调用者处理
    }
  }

  // MARK: - Safety Angle Calculation

  /// 计算本命盘 UI 绘制时星体所需的最小安全角度。
  /// [starBodyRadius]: 星体图标的半径。
  /// [starInnRangeMiddleSize]: 星宿范围中间的大小。
  /// [basicLifeStarCenterCircleSize]: 本命盘中心圆的大小。
  void calculateBasicStarsSafetyAngle(double starBodyRadius,
      double starInnRangeMiddleSize, double basicLifeStarCenterCircleSize) {
    _baseMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
        basicLifeStarCenterCircleSize, starInnRangeMiddleSize, starBodyRadius);
    // 增加额外的填充以优化 UI 外观
    _baseMiniSafetyAngle =
        _baseMiniSafetyAngle.ceilToDouble() + _uiSafetyAnglePadding;
    debugPrint("Base Safety Angle Calculated: $_baseMiniSafetyAngle");
  }

  /// 计算行限盘 UI 绘制时星体所需的最小安全角度。
  /// [starBodyRadius]: 星体图标的半径。
  /// [starInnRangeMiddleSize]: 星宿范围中间的大小。
  /// [lifeStarCenterCircleSize]: 行限盘中心圆的大小。
  void calculateFateStarsSafetyAngle(double starBodyRadius,
      double starInnRangeMiddleSize, double lifeStarCenterCircleSize) {
    _fateMiniSafetyAngle = StarsResolver.calculateMinSafeAngle(
        lifeStarCenterCircleSize, starInnRangeMiddleSize, starBodyRadius);
    // 增加额外的填充以优化 UI 外观
    _fateMiniSafetyAngle =
        _fateMiniSafetyAngle.ceilToDouble() + _uiSafetyAnglePadding;
    debugPrint("Fate Safety Angle Calculated: $_fateMiniSafetyAngle");
  }

  @override
  void dispose() {
    uiFateLifeStarsNotifier.dispose();
    uiBasicLifeStarsNotifier.dispose();
    // uiShenShaNotifier.dispose();
    // uiDestinyGongNotifier.dispose();

    uiBasePanelNotifier.dispose();
    uiDaXianPanelNotifier.dispose();
    baseObserverPositionNotifier.dispose();
    super.dispose();
  }

  // MARK: - State Management

  /// 重置 ViewModel 的所有计算结果和状态。
  void reset() {
    _daXianMapper = null;
    _uiBasicLifeStars = [];
    _uiFateLifeStars = [];
    uiFateLifeStarsNotifier.value = null;
    uiBasicLifeStarsNotifier.value = null;
    uiDaXianPanelNotifier.value = null;
    uiBasePanelNotifier.value = null;
    baseObserverPositionNotifier.value = null;
    _baseMiniSafetyAngle = 0;
    _fateMiniSafetyAngle = 0;

    debugPrint("ViewModel state reset.");
    notifyListeners(); // 通知 UI 状态已清空
  }

  // MARK: - Calculation

  BasePanelConfig panelConfig = BasePanelConfig.defaultBasicPanelConfig();
  FatePanelConfig fatePanelConfig = FatePanelConfig.defaultFatePanelConfig();

  /// 根据观测者位置和时间计算星盘数据。
  /// 这是触发所有计算的主入口。
  /// [observerPosition]: 包含出生信息、行限时间、经纬度、时区等观测者信息。
  Future<void> calculate(ObserverPosition observerPosition) async {
    // // 确保管理器和服务已初始化
    // if (_shenShaManager == null || _huaYaoManager == null) {
    //   await init(); // 如果未初始化则先初始化
    // }
    // 更新服务中的观测者位置
    _generateBasePanelService = GenerateBasePanelService(
        panelConfig: panelConfig, // 默认配置
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
        observerPosition: observerPosition);

    baseObserverPositionNotifier.value = observerPosition;
    debugPrint(
        "Calculating for observer: ${observerPosition.latitude}, ${observerPosition.longitude}");

    // 1. 计算本命盘
    BasePanelModel basicPanelModel;
    try {
      // 1.1 创建计算引擎
      final engine = CalculationEngineFactory.create(panelConfig);

      // 1.2 获取周天模型定义
      final ZhouTianModel zhouTianModel =
          await engine.getSystemDefinition(panelConfig);

      // 1.3 计算星体位置
      final starPositions = await engine.calculateStarPositions(
        observerPosition.dateTime,
        observerPosition,
        panelConfig,
      );

      // 1.4 转换星体位置为 starAngleMapper
      final Map<EnumStars, StarAngleSpeed> starAngleMapper = {};
      for (var pos in starPositions) {
        final rawInfo = pos.angleRawInfoSet.firstWhere(
          (info) =>
              info.panelSystemType == panelConfig.panelSystemType &&
              info.coordinateSystem == panelConfig.celestialCoordinateSystem,
          orElse: () => pos.angleRawInfoSet.first,
        );
        starAngleMapper[pos.starType] = StarAngleSpeed(
          angle: rawInfo.angle,
          speed: rawInfo.speed,
        );
      }

      basicPanelModel = await _generateBasePanelService.calculate(
        zhouTianModel: zhouTianModel,
        starAngleMapper: starAngleMapper,
      );
      // uiBasicLifeStars = // 使用原始角度计算 UI 数据
      uiBasicLifeStarsNotifier.value = _calculateUIStarsFromMapper(
          basicPanelModel.starAngleMapper, _baseMiniSafetyAngle);
      uiBasePanelNotifier.value = basicPanelModel;

      calculateDongWeiFate(bodyLifeModel: basicPanelModel.bodyLifeModel);
      debugPrint(
          "Basic panel calculated. ${uiBasicLifeStarsNotifier.value!.length}");
      final timingInfo = _divinationInfoModel!
          .divinationDatetime.timingInfoListJson!
          .firstWhere((t) =>
              t.uuid ==
              _divinationInfoModel!.divinationDatetime.timingInfoUuid!);
      saveCalculatedPanelUseCase.execute(
          basicPanelModel: basicPanelModel,
          panelConfig: panelConfig,
          divinationDatetimeModel: timingInfo,
          requestInfo: _divinationInfoModel!.divination);
    } catch (e) {
      debugPrint("Error calculating basic panel: $e");
      // 根据需要处理错误
      uiBasicLifeStarsNotifier.value = null;
    }

    calculateDaXian(DateTime.now().add(const Duration(days: 4, hours: 6)));

    // 通知所有监听者（通常是 UI）数据已更新
    // notifyListeners();
    debugPrint("ViewModel calculation complete. Listeners notified.");
  }

  Future<void> calculateDaXian(DateTime fateLifeTime) async {
    fateObserver = generateFateObserverPosition(fateLifeTime);

    // DateTime fateLifeUtcTime = fateLifeTime.toUtc();
    try {
      // 1. 创建计算引擎
      final engine = CalculationEngineFactory.create(panelConfig);

      // 2. 获取周天模型
      final ZhouTianModel zhouTianModel =
          await engine.getSystemDefinition(panelConfig);

      // 3. 计算星体位置
      final starPositions = await engine.calculateStarPositions(
        fateObserver!.dateTime,
        fateObserver!,
        panelConfig,
      );

      // 4. 转换
      final Map<EnumStars, StarAngleSpeed> starAngleMapper = {};
      for (var pos in starPositions) {
        final rawInfo = pos.angleRawInfoSet.firstWhere(
          (info) =>
              info.panelSystemType == panelConfig.panelSystemType &&
              info.coordinateSystem == panelConfig.celestialCoordinateSystem,
          orElse: () => pos.angleRawInfoSet.first,
        );
        starAngleMapper[pos.starType] = StarAngleSpeed(
          angle: rawInfo.angle,
          speed: rawInfo.speed,
        );
      }

      PassageYearPanelModel fatePanelModel =
          await _generateBasePanelService.calculateDaXia(
        uiBasePanelNotifier.value!,
        fateObserver!,
        zhouTianModel: zhouTianModel,
        starAngleMapper: starAngleMapper,
      );

      _uiFateLifeStars = _calculateUIStarsFromMapper(
          fatePanelModel.starAngleMapper,
          _fateMiniSafetyAngle); // 使用原始角度计算 UI 数据

      uiFateLifeStarsNotifier.value = _uiFateLifeStars;
      uiDaXianPanelNotifier.value = fatePanelModel;
      debugPrint("Fate panel calculated. ${_uiFateLifeStars.length}");
    } catch (e) {
      debugPrint("Error calculating fate panel: $e");
      // 根据需要处理错误
      _uiFateLifeStars = [];
      uiFateLifeStarsNotifier.value = null;
    }
  }

  /// 使用 BasePanelModel 中的 StarAngleSpeed 映射计算 UI 星体列表。
  /// 这个方法用于将服务计算的结果转换为 UI 需要的格式。
  /// [starsAngleMapper]: 星体到 StarAngleSpeed 信息的映射。
  /// [miniSafetyAngle]: UI 绘制时星体所需的最小安全角度。
  /// 返回: 适用于 UI 绘制的 UIStarModel 列表。
  List<UIStarModel> _calculateUIStarsFromMapper(
      Map<EnumStars, StarAngleSpeed> starsAngleMapper, double miniSafetyAngle) {
    // 定义星体及其在 UI 调整位置时的优先级。
    // 优先级越高，越不容易被移动。
    List<UIStarModel> unadjustedStarList = [
      UIStarModel(
        star: EnumStars.Sun,
        originalAngle:
            starsAngleMapper[EnumStars.Sun]?.angle ?? 0, // 使用?.处理可能不存在的星体
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
    unadjustedStarList.removeWhere((starModel) =>
        starModel.originalAngle == 0 &&
        starsAngleMapper[starModel.star] == null);

    // 使用 StarsResolver 计算调整后的 UI 位置
    return StarsResolver.resolveUIStars(unadjustedStarList);
  }

  // MARK: - Utility Methods

  /// 检查一个角度是否落在另一个角度范围内。
  /// 能处理范围跨越 0/360 度边界的情况。
  /// [theStartDegree]: 范围的起始角度。
  /// [theEndDegree]: 范围的结束角度。
  /// [doTestDegree]: 需要测试的角度。
  /// 返回: 如果测试角度在范围内则为 true，否则为 false。
  @visibleForTesting // 标记为测试可见，因为它可能是内部辅助方法但逻辑复杂
  static bool isInDegreeRange(
      double theStartDegree, double theEndDegree, double doTestDegree) {
    // 将所有角度规范化到 [0, 360) 范围
    double normalizeAngle(double angle) {
      angle = angle % 360;
      if (angle < 0) {
        angle += 360;
      }
      return angle;
    }

    double startDegree = normalizeAngle(theStartDegree);
    double endDegree = normalizeAngle(theEndDegree);
    double testedDegree = normalizeAngle(doTestDegree);

    // 如果起始角度等于结束角度，表示范围覆盖整个圆，除了起始点本身（取决于包含性）
    // 当前逻辑抛出错误，保留原逻辑，但需注意这种情况可能需要特殊处理
    if (startDegree == endDegree) {
      // 通常表示一个点或整个圆。在角度范围判断中，相等可能表示空范围或整个圆。
      // 根据原代码逻辑，此处认为无效范围。
      debugPrint(
          "isInDegreeRange called with startDegree == endDegree ($startDegree). This might be an edge case or invalid input.");
      return false; // 或者根据具体需求判断是否为整个圆
      // throw ArgumentError("startDegree == endDegree is not a valid range for simple check.");
    }

    if (startDegree < endDegree) {
      // 正常范围，例如 30 到 60 度
      return testedDegree >= startDegree && testedDegree <= endDegree;
    } else {
      // 跨越 0/360 边界的范围，例如 330 到 30 度
      // 测试角度在 [startDegree, 360) 或 [0, endDegree] 范围内
      return testedDegree >= startDegree || testedDegree <= endDegree;
    }
  }

  /// 计算洞微命理信息
  /// [bodyLifeModel]: 身命信息模型
  /// [calculateDaXian]: 是否计算大限，默认为 true
  /// [calculateHundredSix]: 是否计算百六限，默认为 true
  /// [daXianCountingType]: 大限计算类型，默认为现代方法
  /// [hundredSixCountingType]: 百六限计算类型，默认为现代方法
  Future<void> calculateDongWeiFate({
    required BodyLifeModel bodyLifeModel,
  }) async {
    debugPrint("开始计算洞微命理...");

    // 创建计算参数
    final params = CalculateFateDongWeiParams(
      bodyLifeModel: bodyLifeModel,
      countingType: fatePanelConfig.mingCountingType,
    );

    // 执行计算
    final result = await calculateFateDongWeiUseCase.execute(params);
    dongWeiFateResultNotifier.value = result;
  }

  /// 根据当前的基础面板模型计算洞微命理
  /// 这是一个便捷方法，会自动从当前的面板数据中提取身命信息
  Future<void> calculateDongWeiFateFromCurrentPanel() async {
    final basePanelModel = uiBasePanelNotifier.value;
    if (basePanelModel == null) {
      debugPrint("无法计算洞微命理：基础面板模型为空，请先计算星盘");
      return;
    }

    // 从基础面板模型中提取身命信息
    final bodyLifeModel = basePanelModel.bodyLifeModel;
    if (bodyLifeModel == null) {
      debugPrint("无法计算洞微命理：基础面板模型中缺少身命信息");
      return;
    }

    // 执行洞微命理计算
    await calculateDongWeiFate(bodyLifeModel: bodyLifeModel);
  }

  /// 计算紫气在黄道坐标系中的位置。
  /// 这个计算方法基于特定术数规则，非标准天文计算。
  /// [datetime]: 计算紫气位置的时间 (UTC)。
  /// 返回: 紫气在黄道上的角度 (度)。
  double _calculateZiQi(DateTime datetime) {
    // 将目标时间转换为上海时区，以便与基准时间比较
    // 注意：Sweph计算使用UTC时间，但紫气基准是上海时间。
    // 这里假设紫气的运行速度是相对于地球自转的相对速度，因此与本地时间差相关。
    // 如果紫气运行速度是恒定的，与时区无关，则应直接使用UTC时间差。
    // 原代码使用了UTC时间差与上海基准时间比较，这里沿用此逻辑，但需注意其合理性。
    // 更严谨的做法可能是将datetime转换为tz.TZDateTime后再比较
    // 但为了与 Sweph 计算的输入 (UTC DateTime) 一致，且原逻辑使用了UTC时间差，这里保留UTC时间差计算。

    // 假设输入的 datetime 已经是 UTC 时间
    final utcDateTime = datetime;
    // 将上海基准时间转换为 UTC
    final ziQiBaseUtcTime = _ziQiBaseShangHaiTime.toUtc();

    if (utcDateTime.isAtSameMomentAs(ziQiBaseUtcTime)) {
      return 0.0; // 在基准时间点，角度为 0
    }

    // 计算与基准时间的分钟差
    var diffInMinutes = utcDateTime.isBefore(ziQiBaseUtcTime)
        ? ziQiBaseUtcTime.difference(utcDateTime)
        : utcDateTime.difference(ziQiBaseUtcTime);

    // 计算运行角度
    double result = diffInMinutes.inMinutes * _ziQiAnglePerMinute;

    // 如果目标时间早于基准时间，角度应该倒退
    if (utcDateTime.isBefore(ziQiBaseUtcTime)) {
      result = -result;
    }

    // 规范化角度到 [0, 360) 范围
    result = result % 360;
    if (result < 0) {
      result += 360;
    }

    // 保留小数点后两位
    num factor = pow(10, 2);
    result = ((result * factor).round() / factor);

    return result;
  }

  DivinationInfoModel? _divinationInfoModel;

  void setLifeObserver(DivinationInfoModel divinationInfoModel) {
    _divinationInfoModel = divinationInfoModel;
    DatatimeDivinationDetailsDataModel _tmp =
        divinationInfoModel.divinationDatetime;
    observer = _tmp.timingInfoListJson!
        .firstWhere((t) => t.uuid == _tmp.timingInfoUuid)
        .observer;
    lifeObserver = generateLifeObserverPosition();
    logger.d(json.encode(lifeObserver));
  }

  ObserverPosition? lifeObserver;

  ObserverPosition generateLifeObserverPosition() {
    DivinationDatetimeModel _datetimeModel = _divinationInfoModel!
        .divinationDatetime.timingInfoListJson!
        .firstWhere((t) =>
            t.uuid == _divinationInfoModel!.divinationDatetime.timingInfoUuid)!;
    Coordinates _coordinates;
    switch (observer!.type) {
      case EnumDatetimeType.standard:
      case EnumDatetimeType.removeDST:
        _coordinates =
            _datetimeModel.observer.location!.address!.province.coordinates!;
        break;
      case EnumDatetimeType.meanSolar:
        _coordinates =
            _datetimeModel.observer.location!.address!.city?.coordinates ??
                _datetimeModel.observer.location!.address!.province.coordinates;
        break;
      case EnumDatetimeType.trueSolar:
        if (_datetimeModel.observer.isManualCalibration) {
          _coordinates = _datetimeModel.observer.location!.preciseCoordinates!;
        } else {
          _coordinates = _datetimeModel.observer.location!.coordinates!;
        }

        break;
    }
    return ObserverPosition(
      // 假设 divinationDatetime.datetime 已经是包含时区信息的 DateTime
      // 如果不是，需要根据 location.address.timezone 进行转换
      // 原始代码直接使用 .datetime 作为 birthdayUtcTime，这可能是不准确的
      // 正确做法是将 datetime 转换为 UTC 时间
      // 示例：使用 timezone 包将本地时间转换为 UTC
      // birthdayUtcTime: tz.TZDateTime.from(dateTime, tz.getLocation(location.address!.timezone!)).toUtc(),
      // 或者如果 datetime 本身就是 UTC，则直接使用
      // 这里假设 datetime 已经是带有时区信息的 TZDateTime 或需要被视为 UTC
      latitude: _coordinates.latitude,
      longitude: _coordinates.longitude,
      altitude: 0, // 原始代码 altitude 为 0，保留
      timezone: observer!.timezoneStr,
      dateTime: _datetimeModel.datetime, // 保存时区信息
      isDayBirth: getDayTimeZhi().contains(_datetimeModel.timeJiaZi.zhi),
      yearGanZhi: _datetimeModel.yearJiaZi,
      monthGanZhi: _datetimeModel.monthJiaZi,
      dayGanZhi: _datetimeModel.dayJiaZi,
      timeGanZhi: _datetimeModel.timeJiaZi,
    );
  }

  ObserverPosition? fateObserver;
  ObserverPosition generateFateObserverPosition(DateTime fateDatetime) {
    DivinationDatetimeModel _datetimeModel;
    tz.TZDateTime tzDatetime =
        tz.TZDateTime.from(fateDatetime, tz.getLocation(observer!.timezoneStr));
    final isDST = tzDatetime.timeZone.isDst;
    String queryUuid = UuidV7().toString();
    // Coordinates _coordinates;
    switch (observer!.type) {
      case EnumDatetimeType.standard:
        _datetimeModel =
            SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(
          queryUuid: queryUuid,
          dateTime: tzDatetime.toDateTime(),
          timezoneStr: observer!.timezoneStr,
          location: observer!.location,
          isDST: isDST,
          isSeersLocation: false,
        );
        break;
      case EnumDatetimeType.removeDST:
        if (isDST) {
          // 处理夏令时的情况
          // 例如，将时间向前调整一个小时
          tzDatetime = tzDatetime.subtract(Duration(hours: 1));
          _datetimeModel =
              SolarLunarDateTimeHelper.calculateRemoveDSTQueryDateTimeInfo(
            queryUuid: queryUuid,
            dateTime: tzDatetime.toDateTime(),
            timezoneStr: observer!.timezoneStr,
            location: observer!.location,
            hourAdjusted: -1,
            isSeersLocation: false,
          );
        } else {
          _datetimeModel =
              SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(
            queryUuid: queryUuid,
            dateTime: tzDatetime.toDateTime(),
            timezoneStr: observer!.timezoneStr,
            location: observer!.location,
            isDST: isDST,
            isSeersLocation: false,
          );
        }

        break;
      case EnumDatetimeType.meanSolar:
        _datetimeModel =
            SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(
                queryUuid, tzDatetime, observer!.location!.address!, false);
        break;
      case EnumDatetimeType.trueSolar:
        _datetimeModel =
            SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(
                queryUuid,
                tzDatetime.toDateTime(),
                observer!.timezoneStr,
                observer!.coordinate!,
                false);
        break;
    }
    return ObserverPosition(
      // 假设 divinationDatetime.datetime 已经是包含时区信息的 DateTime
      // 如果不是，需要根据 location.address.timezone 进行转换
      // 原始代码直接使用 .datetime 作为 birthdayUtcTime，这可能是不准确的
      // 正确做法是将 datetime 转换为 UTC 时间
      // 示例：使用 timezone 包将本地时间转换为 UTC
      // birthdayUtcTime: tz.TZDateTime.from(dateTime, tz.getLocation(location.address!.timezone!)).toUtc(),
      // 或者如果 datetime 本身就是 UTC，则直接使用
      // 这里假设 datetime 已经是带有时区信息的 TZDateTime 或需要被视为 UTC
      latitude: _datetimeModel.observer.coordinate!.latitude,
      longitude: _datetimeModel.observer.coordinate!.longitude,
      altitude: 0, // 原始代码 altitude 为 0，保留
      timezone: observer!.timezoneStr,
      dateTime: _datetimeModel.datetime, // 保存时区信息
      isDayBirth: getDayTimeZhi().contains(_datetimeModel.timeJiaZi.zhi),
      yearGanZhi: _datetimeModel.yearJiaZi,
      monthGanZhi: _datetimeModel.monthJiaZi,
      dayGanZhi: _datetimeModel.dayJiaZi,
      timeGanZhi: _datetimeModel.timeJiaZi,
    );
  }

  /// 将 DivinationInfoModel 转换为 ObserverPosition。
  /// [divinationInfo]: 包含问事时间、地点等信息的数据模型。
  /// 返回: ObserverPosition 对象。
  ObserverPosition convertToObserverPosition(
      DivinationInfoModel divinationInfo) {
    DatatimeDivinationDetailsDataModel _tmp = divinationInfo.divinationDatetime;
    observer = _tmp.timingInfoListJson!
        .firstWhere((t) => t.uuid == _tmp.timingInfoUuid)
        .observer;

    // 确保日期时间信息有效
    final dateTime = _tmp.datetime;
    final location = _tmp.location;

    if (location == null ||
        location.coordinates == null ||
        location.address == null) {
      throw ArgumentError(
          "DivinationInfoModel must contain valid datetime, location, coordinates, and timezone.");
    }

    return ObserverPosition(
      // 假设 divinationDatetime.datetime 已经是包含时区信息的 DateTime
      // 如果不是，需要根据 location.address.timezone 进行转换
      // 原始代码直接使用 .datetime 作为 birthdayUtcTime，这可能是不准确的
      // 正确做法是将 datetime 转换为 UTC 时间
      // 示例：使用 timezone 包将本地时间转换为 UTC
      // birthdayUtcTime: tz.TZDateTime.from(dateTime, tz.getLocation(location.address!.timezone!)).toUtc(),
      // 或者如果 datetime 本身就是 UTC，则直接使用
      // 这里假设 datetime 已经是带有时区信息的 TZDateTime 或需要被视为 UTC
      latitude: location.coordinates!.latitude,
      longitude: location.coordinates!.longitude,
      altitude: 0, // 原始代码 altitude 为 0，保留
      timezone: location.address!.timezone,
      dateTime: dateTime, // 保存时区信息
      isDayBirth: getDayTimeZhi()
          .contains(divinationInfo.divinationDatetime.timeGanZhi.diZhi),
      yearGanZhi: divinationInfo.divinationDatetime.yearGanZhi,
      monthGanZhi: divinationInfo.divinationDatetime.monthGanZhi,
      dayGanZhi: divinationInfo.divinationDatetime.dayGanZhi,
      timeGanZhi: divinationInfo.divinationDatetime.timeGanZhi,
    );
  }

  static List<DiZhi> getDayTimeZhi() {
    return [
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN
    ];
  }

  // MARK: - Data Loading

  /// 异步加载神煞数据。
  /// 从 asset 文件读取 JSON 并解析为 ShenShaManager。
  /// 返回: ShenShaManager 实例。
  Future<ShenShaManager> _loadShenShaManager() async {
    debugPrint("Loading ShenSha data...");
    try {
      // 并行加载所有神煞数据文件
      await Future.wait([
        rootBundle.loadString('assets/shen_sha/74_shensha_tiangan.json'),
        rootBundle.loadString('assets/shen_sha/74_shensha_dizhi_year.json'),
        rootBundle.loadString('assets/shen_sha/74_shensha_dizhi_month.json'),
        rootBundle.loadString('assets/shen_sha/74_shensha_ganzhi.json'),
        rootBundle.loadString('assets/shen_sha/74_shensha_bundle.json'),
        rootBundle.loadString('assets/shen_sha/74_shensha_others.json'),
      ]);

      debugPrint("ShenSha data loaded successfully.");
      return ShenShaManager(
          shenShaService: ShenShaService(
              repository: ShenShaRepositoryImpl(
                  localDataSource: ShenShaLocalDataSourceImpl())));
      // return ShenShaManager(
      //     tianGanShenSha: tianGanShenSha,
      //     yearDiZhiShenSha: yearDiZhiShenSha,
      //     monthDiZhiShenSha: monthDiZhiShenSha,
      //     ganZhiShenSha: ganzhiShenSha,
      //     bundledShenSha: bundledShenSha,
      //     otherShenSha: otherShenSha);
    } catch (e) {
      debugPrint("Error loading ShenSha data: $e");
      // 加载失败，可能需要抛出错误或返回一个空管理器
      throw Exception("Failed to load ShenSha data: $e");
    }
  }

  /// 异步加载化曜数据。
  /// 从 asset 文件读取 JSON 并解析为 HuaYaoManager。
  /// 返回: HuaYaoManager 实例。
  Future<HuaYaoManager> _loadHuaYaoManager() async {
    debugPrint("Loading HuaYao data...");
    try {
      await Future.wait([
        rootBundle.loadString('assets/shen_sha/74_huayao_tiangan.json'),
        rootBundle.loadString('assets/shen_sha/74_huayao_dizhi.json'),
        rootBundle.loadString('assets/shen_sha/74_huayao_others.json'),
      ]);

      debugPrint("HuaYao data loaded successfully.");

      return HuaYaoManager(
          huaYaoService: HuaYaoService(
              repository: HuaYaoRepositoryImpl(
                  localDataSource: HuaYaoLocalDataSourceImpl())));
      // return HuaYaoManager(
      //   tianGanHuaYao: tianGanHuaYao,
      //   diZhiHuaYao: diZhiHuaYao,
      //   othersHuaYao: othersHuaYao,
      // );
    } catch (e) {
      debugPrint("Error loading HuaYao data: $e");
      // 加载失败，可能需要抛出错误或返回一个空管理器
      throw Exception("Failed to load HuaYao data: $e");
    }
  }

  // MARK: - New Calculation using Service

  /// 使用 GenerateBasePanelService 计算星盘数据。
  /// 这是新的计算流程，calculate 方法将调用此方法。
  /// [calculateTime]: 需要计算星盘的时间 (UTC)。
  /// 返回: BasePanelModel 包含计算出的星体角度和速度等基础信息。
  Future<BasePanelModel> _calculatePanelWithService(
      {required DateTime calculateTime}) async {
    // 确保服务已初始化
    if (_shenShaManager == null ||
        _huaYaoManager == null ||
        baseObserverPositionNotifier.value == null) {
      throw StateError(
          'ViewModel not fully initialized before calling _calculatePanelWithService.');
    }

    // 1. 创建计算引擎
    final engine = CalculationEngineFactory.create(panelConfig);

    // 2. 获取周天模型定义
    final ZhouTianModel zhouTianModel =
        await engine.getSystemDefinition(panelConfig);

    // 3. 计算星体位置
    final observerPosition = baseObserverPositionNotifier.value!;
    final starPositions = await engine.calculateStarPositions(
      calculateTime,
      observerPosition,
      panelConfig,
    );

    // 4. 转换星体位置为 starAngleMapper
    final Map<EnumStars, StarAngleSpeed> starAngleMapper = {};
    for (var pos in starPositions) {
      final rawInfo = pos.angleRawInfoSet.firstWhere(
        (info) =>
            info.panelSystemType == panelConfig.panelSystemType &&
            info.coordinateSystem == panelConfig.celestialCoordinateSystem,
        orElse: () => pos.angleRawInfoSet.first,
      );
      starAngleMapper[pos.starType] = StarAngleSpeed(
        angle: rawInfo.angle,
        speed: rawInfo.speed,
      );
    }

    return _generateBasePanelService.calculate(
      zhouTianModel: zhouTianModel,
      starAngleMapper: starAngleMapper,
    );
  }

  // late final App74Database _database;

  // 在构造函数或初始化方法中初始化
  // void _initializeUseCases() {
  //   _database = App74Database();
  //   _saveCalculatedPanelUseCase =
  //       SaveCalculatedPanelUseCase(_database.basePanelDao);
  // }

  // 修改现有的计算方法
  // Future<void> calculatePanel() async {
  //   try {
  //     basicPanelModel = await _generateBasePanelService.calculate();

  //     // 保存计算结果到数据库
  //     final savedUuid = await _saveCalculatedPanelUseCase.execute(
  //       basicPanelModel: basicPanelModel,
  //       panelConfig: panelConfig, // 需要传入当前的配置
  //       observerPosition: observerPosition, // 需要传入当前的观测位置
  //       divinationUuid: currentDivinationUuid, // 如果有的话
  //       seekerUuid: currentSeekerUuid, // 如果有的话
  //     );

  //     print('面板数据已保存，UUID: $savedUuid');
  //   } catch (e) {
  //     print('保存面板数据失败: $e');
  //     // 处理错误
  //   }
  // }
}
