import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_evaluator.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_input_builder.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_product_repository.dart';

/// 格局评估服务
///
/// 连接 [GeJuProductRepository]（仓储接口）与 [GeJuEvaluator]（评估引擎）。
/// 负责从 Repository 加载并组装 [RuleEvaluationData]，然后调用评估器。
class GeJuEvaluationService {
  final GeJuProductRepository _repository;

  /// 组装好的规则数据缓存（避免每次评估重复加载）
  List<RuleEvaluationData>? _assembledRuleDataCache;

  /// 是否启用预过滤器（debug 用，可运行时切换）
  bool usePreFilter = true;

  GeJuEvaluationService({required GeJuProductRepository repository})
      : _repository = repository;

  /// 使缓存失效（CRUD 操作后调用）
  void invalidateRuleDataCache() {
    _assembledRuleDataCache = null;
  }

  /// 评估命盘格局
  ///
  /// [panelModel]        基础命盘模型
  /// [starsSet]          十一星体信息集合
  /// [monthZhi]          出生月地支
  /// [yearJiaZi]         出生年甲子
  /// [coordinateSystem]  坐标系（默认黄道）
  /// [preferredSchools]  偏好流派 ID 集合（默认 guo_lao）
  /// [onlyMatched]       是否只返回匹配项
  Future<GeJuEvaluationSummary> evaluateNatalChart({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem =
        CelestialCoordinateSystem.Ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
    bool onlyMatched = false,
  }) async {
    final input = GeJuInputBuilder.buildFromPanel(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      coordinateSystem: coordinateSystem,
      preferredSchools: preferredSchools,
    );

    final ruleData = await _assembleRuleData();

    final sw = Stopwatch()..start();
    final summary = GeJuEvaluator.evaluateWithConditionSets(
      input: input,
      ruleData: ruleData,
      onlyMatched: onlyMatched,
      usePreFilter: usePreFilter,
    );
    sw.stop();

    final timed = summary.withTiming(sw.elapsedMilliseconds);
    _printEvaluationSummary('NatalChart', timed);
    return timed;
  }

  /// 评估行限格局
  ///
  /// 额外需要 [xianGong] 和 [xianConstellation]；只评估 scope 为
  /// `xingxian` 或 `both` 的规则。
  Future<GeJuEvaluationSummary> evaluateXingXian({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    required EnumTwelveGong xianGong,
    required Enum28Constellations xianConstellation,
    CelestialCoordinateSystem coordinateSystem =
        CelestialCoordinateSystem.Ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
    bool onlyMatched = false,
  }) async {
    final input = GeJuInputBuilder.buildForXingXian(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      xianGong: xianGong,
      xianConstellation: xianConstellation,
      coordinateSystem: coordinateSystem,
      preferredSchools: preferredSchools,
    );

    final ruleData = await _assembleRuleData();

    final sw = Stopwatch()..start();
    final summary = GeJuEvaluator.evaluateWithConditionSets(
      input: input,
      ruleData: ruleData,
      onlyMatched: onlyMatched,
      usePreFilter: usePreFilter,
    );
    sw.stop();

    final timed = summary.withTiming(sw.elapsedMilliseconds);
    _printEvaluationSummary('XingXian', timed);
    return timed;
  }

  /// 使用已构建好的 [GeJuInput] 直接评估（高级用法）
  Future<GeJuEvaluationSummary> evaluateWithInput({
    required GeJuInput input,
    bool onlyMatched = false,
  }) async {
    final ruleData = await _assembleRuleData();
    return GeJuEvaluator.evaluateWithConditionSets(
      input: input,
      ruleData: ruleData,
      onlyMatched: onlyMatched,
    );
  }

  // ── 内部辅助 ────────────────────────────────────────────────────────────

  /// 输出评估汇总日志
  void _printEvaluationSummary(String label, GeJuEvaluationSummary summary) {
    final mode = usePreFilter ? 'optimized' : 'classic';
    print('GeJu[$label|$mode] ${summary.matchedCount}/${summary.totalCount} matched '
        '| preFilterRejected=${summary.totalPreFilterRejected} '
        '| conditionMissing=${summary.totalConditionMissing} '
        '| errors=${summary.totalEvaluationErrors} '
        '| scopeSkipped=${summary.totalScopeSkipped} '
        '| ${summary.evaluationDurationMs}ms');
  }

  /// 从 Repository 加载所有规则及其关联数据，组装为评估所需的 [RuleEvaluationData] 列表。
  ///
  /// 使用批量加载 + 缓存，避免 N 次逐条查询。
  Future<List<RuleEvaluationData>> _assembleRuleData() async {
    if (_assembledRuleDataCache != null) return _assembledRuleDataCache!;

    final rules = await _repository.loadAllRules();
    final csMap = await _repository.loadAllConditionSetsGrouped();
    final annMap = await _repository.loadAllAnnotationsGrouped();

    _assembledRuleDataCache = rules.map((rule) {
      return RuleEvaluationData(
        rule: rule,
        conditionSets: csMap[rule.id] ?? [],
        annotations: annMap[rule.id] ?? [],
      );
    }).toList();

    return _assembledRuleDataCache!;
  }
}
