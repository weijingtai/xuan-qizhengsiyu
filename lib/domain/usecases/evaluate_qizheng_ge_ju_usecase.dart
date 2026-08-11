import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../entities/models/base_panel_model.dart';
import '../entities/models/eleven_stars_info.dart';
import '../entities/models/ge_ju/ge_ju_result.dart';
import '../services/ge_ju_evaluation_service.dart';
import '../../enums/enum_panel_system_type.dart';
import '../../enums/enum_star_position_status.dart';
import '../../enums/enum_twelve_gong.dart';
import '../../dataset/star_position_status_model.dart';

/// XRAP contract（raw: {id, className, star, starPositionStatusType,
/// positionList: [宫位中文]}）→ 领域模型。
///
/// 数据值为中文（star='日'、starPositionStatusType='庙'、positionList=['戌']），
/// 按枚举中文名匹配（EnumStars.singleName / EnumStarGongPositionStatusType.name /
/// EnumTwelveGong.name）。
List<StarPositionStatusDatasetModel<EnumTwelveGong>>
    convertStarPositionStatusContracts(
        List<QiZhengStarPositionStatusContract> contracts) {
  return contracts.map((c) {
    final raw = c.raw;
    return StarPositionStatusDatasetModel<EnumTwelveGong>(
      id: raw['id'] as int,
      className: raw['className'] as String,
      star: EnumStars.values.firstWhere((s) =>
          s.singleName == raw['star'] ||
          s.starName == raw['star'] ||
          s.name == raw['star']),
      starPositionStatusType: EnumStarGongPositionStatusType.values
          .firstWhere((t) => t.name == raw['starPositionStatusType']),
      positionList: (raw['positionList'] as List)
          .map((g) => EnumTwelveGong.values.firstWhere((g2) => g2.name == g))
          .toList(),
    );
  }).toList();
}

class EvaluateQiZhengGeJuUseCase {
  final GeJuEvaluationService geJuEvaluationService;

  /// 星曜庙旺状态数据源（XRAP `qizheng.star_position_status`，97 行）。
  /// 提供后 `starGongStatus` 类条件可真正评估（否则恒 false）。
  final QiZhengStarPositionStatusRepository? positionStatusRepo;

  List<StarPositionStatusDatasetModel<EnumTwelveGong>>? _statusCache;

  EvaluateQiZhengGeJuUseCase({
    required this.geJuEvaluationService,
    this.positionStatusRepo,
  });

  Future<GeJuEvaluationSummary> execute({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem =
        CelestialCoordinateSystem.Ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
    bool onlyMatched = false,
  }) async {
    return geJuEvaluationService.evaluateNatalChart(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      coordinateSystem: coordinateSystem,
      preferredSchools: preferredSchools,
      onlyMatched: onlyMatched,
      starStatusDataList: await _loadStarStatusData(),
    );
  }

  /// 加载星曜庙旺状态（懒加载缓存一次；无数据源返回 null，不崩不刷警告）。
  Future<List<StarPositionStatusDatasetModel<EnumTwelveGong>>?> _loadStarStatusData() async {
    final repo = positionStatusRepo;
    if (repo == null) return null;
    if (_statusCache != null) return _statusCache;
    final contracts = await repo.loadStarPositionStatus();
    final converted = convertStarPositionStatusContracts(contracts);
    _statusCache = converted;
    return converted;
  }

  void invalidateCache() {
    geJuEvaluationService.invalidateRuleDataCache();
    _statusCache = null;
  }

  bool get usePreFilter => geJuEvaluationService.usePreFilter;

  set usePreFilter(bool value) {
    geJuEvaluationService.usePreFilter = value;
  }
}
