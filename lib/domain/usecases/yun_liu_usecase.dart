import 'package:metaphysics_core/domain/calculators/liu_yun/services/yun_liu_service.dart';
import 'package:metaphysics_core/domain/calculators/liu_yun/models/yun_liu_display_models.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:enumeration/enums.dart';
import 'package:metaphysics_core/helpers/solar_lunar_datetime_helper.dart';
import 'package:metaphysics_core/models/calculation_strategy_config_logic_model.dart';

/// 大运流年计算用例 — 包住 metaphysics_core 的 YunLiuService,
/// presentation 层(YunLiuViewModel)不再直接依赖 calculator service。
final class YunLiuUseCase {
  final YunLiuService _service;

  YunLiuUseCase({YunLiuService? service}) : _service = service ?? YunLiuService();

  /// 暴露底层 service 供 calendar 包的 YunLiuViewModel 构造使用。
  /// presentation 层通过 UseCase 间接获取,不直接 import YunLiuService。
  YunLiuService get service => _service;

  List<DaYunDisplayData> calculateDaYunList({
    required DateTime birthDateTime,
    required Gender gender,
    required ChineseDateInfo birthDateInfo,
  }) =>
      _service.calculateDaYunList(
        birthDateTime: birthDateTime,
        gender: gender,
        birthDateInfo: birthDateInfo,
      );

  List<LiuRiDisplayData> fetchLiuRiData(int year, int month, TianGan dayMaster) =>
      _service.fetchLiuRiData(year, month, dayMaster);

  List<LiuShiDisplayData> fetchLiuShiData(
          int year, int month, int day, TianGan dayMaster) =>
      _service.fetchLiuShiData(year, month, day, dayMaster);

  /// 出生阴历信息(原 QiZhengSiYuViewModel.buildYunLiuViewModel 内联计算上移)。
  /// 子时策略固定 noDistinguishAt23,与原 VM 逐字一致。
  ChineseDateInfo computeBirthDateInfo(DateTime dateTime) {
    return SolarLunarDateTimeHelper.cacluateChineseDateInfoV2(
      dateTime,
      CalculationStrategyConfigLogicModel.defaultConfig.copyWith(
        ziStrategy: ZiShiStrategy.noDistinguishAt23,
      ),
    );
  }
}
