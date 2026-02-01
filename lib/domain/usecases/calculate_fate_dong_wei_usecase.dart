import '../entities/models/body_life_model.dart';
import '../entities/models/fate_dong_wei_da_xian.dart';
import '../managers/fate/dong_wei_da_xian_manager.dart';
import '../managers/fate/dong_wei_hundred_six_manager.dart';

/// 计算洞微命运UseCase的参数
class CalculateFateDongWeiParams {
  /// 身命模型，包含命宫和身宫信息
  final BodyLifeModel bodyLifeModel;

  /// 大限计算类型（古代、现代、百六限）
  final DongWeiDaXianMingGongCountingType countingType;

  /// 是否同时计算百六限（可选）
  // final bool calculateHundredSix;

  const CalculateFateDongWeiParams({
    required this.bodyLifeModel,
    required this.countingType,
    // this.calculateHundredSix = false,
  });
}

/// 洞微命运计算结果
class CalculateFateDongWeiResult {
  /// 大限计算结果
  final DongWeiFate daXianResult;

  /// 百六限计算结果（如果请求计算）
  final DongWeiFate? hundredSixResult;

  /// 计算成功标志
  final bool isSuccess;

  /// 错误信息（如果有）
  final String? errorMessage;

  const CalculateFateDongWeiResult({
    required this.daXianResult,
    this.hundredSixResult,
    this.isSuccess = true,
    this.errorMessage,
  });

  /// 创建错误结果
  factory CalculateFateDongWeiResult.error(String errorMessage) {
    return CalculateFateDongWeiResult(
      daXianResult: DongWeiFate(
        type: DongWeiDaXianMingGongCountingType.Modern,
        daXianGongs: [],
      ),
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// 计算洞微命运UseCase
///
/// 该UseCase负责协调 DongWeiDaXianManager 和 DongWeiHundredSixManager
/// 来计算洞微命理中的大限和百六限信息
class CalculateFateDongWeiUseCase {
  final DongWeiDaXianManager _daXianManager;
  final DongWeiHundredSixManager _hundredSixManager;

  CalculateFateDongWeiUseCase({
    DongWeiDaXianManager? daXianManager,
    DongWeiHundredSixManager? hundredSixManager,
  })  : _daXianManager = daXianManager ?? DongWeiDaXianManager(),
        _hundredSixManager = hundredSixManager ?? DongWeiHundredSixManager();

  /// 执行洞微命运计算
  ///
  /// [params] 计算参数，包含身命模型和计算类型
  ///
  /// 返回 [CalculateFateDongWeiResult] 包含计算结果或错误信息
  CalculateFateDongWeiResult execute(CalculateFateDongWeiParams params) {
    try {
      // 验证输入参数
      if (!_validateParams(params)) {
        return CalculateFateDongWeiResult.error('输入参数验证失败：身命模型数据不完整');
      }

      // 计算大限
      final DongWeiFate daXianResult = _daXianManager.calculate(
        params.countingType,
        params.bodyLifeModel,
      );

      // 如果请求计算百六限
      DongWeiFate? hundredSixResult = _hundredSixManager.calculate(
        DongWeiDaXianMingGongCountingType.HundredSix,
        params.bodyLifeModel,
      );

      return CalculateFateDongWeiResult(
        daXianResult: daXianResult,
        hundredSixResult: hundredSixResult,
        isSuccess: true,
      );
    } catch (e) {
      return CalculateFateDongWeiResult.error('计算洞微命运时发生错误: ${e.toString()}');
    }
  }

  /// 仅计算大限
  ///
  /// [bodyLifeModel] 身命模型
  /// [countingType] 计算类型
  ///
  /// 返回 [DongWeiFate] 大限计算结果
  Future<DongWeiFate> calculateDaXianOnly(
    BodyLifeModel bodyLifeModel,
    DongWeiDaXianMingGongCountingType countingType,
  ) async {
    try {
      return _daXianManager.calculate(countingType, bodyLifeModel);
    } catch (e) {
      throw Exception('计算大限失败: ${e.toString()}');
    }
  }

  /// 仅计算百六限
  ///
  /// [bodyLifeModel] 身命模型
  ///
  /// 返回 [DongWeiFate] 百六限计算结果
  Future<DongWeiFate> calculateHundredSixOnly(
    BodyLifeModel bodyLifeModel,
  ) async {
    try {
      return _hundredSixManager.calculate(
        DongWeiDaXianMingGongCountingType.HundredSix,
        bodyLifeModel,
      );
    } catch (e) {
      throw Exception('计算百六限失败: ${e.toString()}');
    }
  }

  /// 比较不同计算方法的结果
  ///
  /// [bodyLifeModel] 身命模型
  ///
  /// 返回包含古代、现代和百六限三种计算结果的Map
  Future<Map<DongWeiDaXianMingGongCountingType, DongWeiFate>> compareAllMethods(
    BodyLifeModel bodyLifeModel,
  ) async {
    try {
      final results = <DongWeiDaXianMingGongCountingType, DongWeiFate>{};

      // 计算古代方法
      results[DongWeiDaXianMingGongCountingType.Ancient] = _daXianManager
          .calculate(DongWeiDaXianMingGongCountingType.Ancient, bodyLifeModel);

      // 计算现代方法
      results[DongWeiDaXianMingGongCountingType.Modern] = _daXianManager
          .calculate(DongWeiDaXianMingGongCountingType.Modern, bodyLifeModel);

      // 计算百六限
      results[DongWeiDaXianMingGongCountingType.HundredSix] =
          _hundredSixManager.calculate(
              DongWeiDaXianMingGongCountingType.HundredSix, bodyLifeModel);

      return results;
    } catch (e) {
      throw Exception('比较计算方法失败: ${e.toString()}');
    }
  }

  /// 验证输入参数
  bool _validateParams(CalculateFateDongWeiParams params) {
    // 检查身命模型是否为空
    if (params.bodyLifeModel == null) {
      return false;
    }

    // 检查命宫信息是否完整
    if (params.bodyLifeModel.lifeGongInfo == null) {
      return false;
    }

    // 检查身宫信息是否完整
    if (params.bodyLifeModel.bodyGongInfo == null) {
      return false;
    }

    return true;
  }
}

/// 自定义异常类
class FateDongWeiCalculationException implements Exception {
  final String message;
  final dynamic originalError;

  const FateDongWeiCalculationException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'FateDongWeiCalculationException: $message\nOriginal error: $originalError';
    }
    return 'FateDongWeiCalculationException: $message';
  }
}
