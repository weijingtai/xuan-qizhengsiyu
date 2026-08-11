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

/// 二十八宿 → 所在十二宫（古法分宫：每宫 30° 含若干宿）。
/// 数据中「殿/贵」状态以二十八宿标注（如土殿=柳女胃氐），模型
/// positionList 为 `EnumTwelveGong`，转换时映射到宿所在宫。
const Map<String, EnumTwelveGong> _kSuToGong = {
  '角': EnumTwelveGong.Chen,
  '亢': EnumTwelveGong.Chen,
  '氐': EnumTwelveGong.Mao,
  '房': EnumTwelveGong.Mao,
  '心': EnumTwelveGong.Mao,
  '尾': EnumTwelveGong.Yin,
  '箕': EnumTwelveGong.Yin,
  '斗': EnumTwelveGong.Chou,
  '牛': EnumTwelveGong.Chou,
  '女': EnumTwelveGong.Zi,
  '虚': EnumTwelveGong.Zi,
  '危': EnumTwelveGong.Zi,
  '室': EnumTwelveGong.Hai,
  '壁': EnumTwelveGong.Hai,
  '奎': EnumTwelveGong.Xu,
  '娄': EnumTwelveGong.Xu,
  '胃': EnumTwelveGong.You,
  '昴': EnumTwelveGong.You,
  '毕': EnumTwelveGong.You,
  '觜': EnumTwelveGong.Shen,
  '参': EnumTwelveGong.Shen,
  '井': EnumTwelveGong.Wei,
  '鬼': EnumTwelveGong.Wei,
  '柳': EnumTwelveGong.Wu,
  '星': EnumTwelveGong.Wu,
  '张': EnumTwelveGong.Wu,
  '翼': EnumTwelveGong.Si,
  '轸': EnumTwelveGong.Si,
};

/// XRAP contract（raw: {id, className, star, starPositionStatusType,
/// positionList: [位置中文]}）→ 领域模型。
///
/// 数据值为中文：star='日'（EnumStars.singleName）、
/// starPositionStatusType='庙'（EnumStarGongPositionStatusType.name）、
/// positionList 混合十二宫（'戌'）与二十八宿（'角'，殿/贵状态）——
/// 宿名经 [_kSuToGong] 映射到所在宫。
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
          .map((g) => _kSuToGong[g] ??
              EnumTwelveGong.values.firstWhere((g2) => g2.name == g))
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
