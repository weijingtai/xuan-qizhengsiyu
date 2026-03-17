import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_variant.dart';
import 'ge_ju_rule.dart';

/// 格局评估状态
enum GeJuEvaluationStatus {
  /// 条件评估通过
  matched,

  /// 条件评估不通过
  unmatched,

  /// 无 ConditionSet（规则没有关联的条件集）
  conditionSetMissing,

  /// ConditionSet 存在但 conditions 为 null
  conditionMissing,

  /// 条件评估抛异常
  evaluationError,

  /// scope 不适用（如本命盘跳过行限规则）
  scopeSkipped,

  /// 预过滤器判定条件不可能满足（快速跳过，未进入完整 evaluate）
  preFilterRejected,
}

/// 格局判断结果模型
/// 代表一个格局规则对命盘的评估结果
class GeJuResult {
  /// 格局规则ID
  final String patternId;

  /// 格局名称
  final String patternName;

  /// 是否匹配
  final bool matched;

  /// 吉凶属性
  final JiXiongEnum jiXiong;

  /// 格局类型 (贫/贱/富/贵/夭/寿/贤/愚)
  final GeJuType geJuType;

  /// 格局描述
  final String description;

  /// 出处
  final String source;

  /// 适用范围
  final GeJuScope scope;

  /// 匹配的条件描述列表（用于展示为什么匹配）
  final List<String> matchedConditionDescriptions;

  /// 匹配的流派列表
  final List<String> matchSchools;

  /// 匹配的 ConditionSet ID（新模型）
  final String? conditionSetId;

  /// 评估状态（区分"不匹配"与"无法评估"等情形）
  final GeJuEvaluationStatus evaluationStatus;

  GeJuResult({
    required this.patternId,
    required this.patternName,
    required this.matched,
    required this.jiXiong,
    required this.geJuType,
    required this.description,
    required this.source,
    required this.scope,
    this.matchedConditionDescriptions = const [],
    this.matchSchools = const [],
    this.conditionSetId,
    this.evaluationStatus = GeJuEvaluationStatus.unmatched,
  });

  /// 从 GeJuRule 和匹配状态创建结果 (Legacy support)
  factory GeJuResult.fromRule(
    GeJuRule rule, {
    required bool matched,
    List<String> matchedConditionDescriptions = const [],
  }) {
    return GeJuResult(
      patternId: rule.id,
      patternName: rule.name,
      matched: matched,
      // ignore: deprecated_member_use_from_same_package
      jiXiong: rule.jiXiong,
      // ignore: deprecated_member_use_from_same_package
      geJuType: rule.geJuType,
      // ignore: deprecated_member_use_from_same_package
      description: rule.description,
      // ignore: deprecated_member_use_from_same_package
      source: rule.source,
      scope: rule.scope,
      matchedConditionDescriptions: matchedConditionDescriptions,
      matchSchools: [],
    );
  }

  /// 从 GeJuRule + GeJuVariant 创建结果 (Legacy)
  @Deprecated('Use GeJuResult.fromConditionSet instead')
  factory GeJuResult.fromVariant(
    GeJuRule rule,
    GeJuVariant variant, {
    required bool matched,
    List<String> matchedConditionDescriptions = const [],
  }) {
    return GeJuResult(
      patternId: rule.id,
      patternName: rule.name,
      matched: matched,
      jiXiong: variant.jiXiong,
      geJuType: variant.geJuType,
      description: variant.description,
      source: variant.source,
      scope: rule.scope,
      matchedConditionDescriptions: matchedConditionDescriptions,
      matchSchools: variant.schools,
    );
  }

  /// 从 GeJuRule + GeJuConditionSet + 可选 GeJuAnnotation 创建结果 (推荐)
  factory GeJuResult.fromConditionSet(
    GeJuRule rule,
    GeJuConditionSet cs, {
    GeJuAnnotation? annotation,
    required bool matched,
    List<String> matchedConditionDescriptions = const [],
    GeJuEvaluationStatus evaluationStatus = GeJuEvaluationStatus.unmatched,
  }) {
    return GeJuResult(
      patternId: rule.id,
      patternName: rule.name,
      matched: matched,
      jiXiong: annotation?.jiXiong ?? JiXiongEnum.PING,
      geJuType: annotation?.geJuType ?? GeJuType.pin,
      description: annotation?.description ?? '',
      source: cs.source?.bookName ?? '',
      scope: rule.scope,
      matchedConditionDescriptions: matchedConditionDescriptions,
      matchSchools: cs.schools ?? [],
      conditionSetId: cs.id,
      evaluationStatus: evaluationStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patternId': patternId,
      'patternName': patternName,
      'matched': matched,
      'jiXiong': jiXiong.name,
      'geJuType': geJuType.name,
      'description': description,
      'source': source,
      'scope': scope.name,
      'matchedConditionDescriptions': matchedConditionDescriptions,
      'matchSchools': matchSchools,
      if (conditionSetId != null) 'conditionSetId': conditionSetId,
      'evaluationStatus': evaluationStatus.name,
    };
  }

  @override
  String toString() {
    return 'GeJuResult{name: $patternName, matched: $matched, jiXiong: ${jiXiong.name}, type: ${geJuType.name}}';
  }
}

/// 格局判断的汇总结果
/// 包含所有匹配和未匹配的格局
class GeJuEvaluationSummary {
  /// 所有被评估的格局结果
  final List<GeJuResult> allResults;

  /// 评估时间
  final DateTime evaluatedAt;

  /// 评估耗时（毫秒），null 表示未计时
  final int? evaluationDurationMs;

  GeJuEvaluationSummary({
    required this.allResults,
    DateTime? evaluatedAt,
    this.evaluationDurationMs,
  }) : evaluatedAt = evaluatedAt ?? DateTime.now();

  /// 附加计时信息，返回新实例
  GeJuEvaluationSummary withTiming(int durationMs) {
    return GeJuEvaluationSummary(
      allResults: allResults,
      evaluatedAt: evaluatedAt,
      evaluationDurationMs: durationMs,
    );
  }

  /// 获取所有匹配的格局
  List<GeJuResult> get matchedPatterns =>
      allResults.where((r) => r.matched).toList();

  /// 获取所有吉格局
  List<GeJuResult> get matchedAuspiciousPatterns =>
      matchedPatterns.where((r) => r.jiXiong.isJi()).toList();

  /// 获取所有凶格局
  List<GeJuResult> get matchedInauspiciousPatterns =>
      matchedPatterns.where((r) => r.jiXiong.isXiong()).toList();

  /// 按格局类型分组获取匹配结果
  Map<GeJuType, List<GeJuResult>> get matchedByType {
    final map = <GeJuType, List<GeJuResult>>{};
    for (var result in matchedPatterns) {
      map.putIfAbsent(result.geJuType, () => []).add(result);
    }
    return map;
  }

  /// 匹配数量
  int get matchedCount => matchedPatterns.length;

  /// 总评估数量
  int get totalCount => allResults.length;

  /// 条件缺失数量（ConditionSet 存在但 conditions 为 null）
  int get totalConditionMissing => allResults
      .where((r) => r.evaluationStatus == GeJuEvaluationStatus.conditionMissing)
      .length;

  /// ConditionSet 缺失数量
  int get totalConditionSetMissing => allResults
      .where((r) => r.evaluationStatus == GeJuEvaluationStatus.conditionSetMissing)
      .length;

  /// 评估错误数量
  int get totalEvaluationErrors => allResults
      .where((r) => r.evaluationStatus == GeJuEvaluationStatus.evaluationError)
      .length;

  /// Scope 跳过数量
  int get totalScopeSkipped => allResults
      .where((r) => r.evaluationStatus == GeJuEvaluationStatus.scopeSkipped)
      .length;

  /// 预过滤器拒绝数量（条件不可能满足，快速跳过）
  int get totalPreFilterRejected => allResults
      .where((r) => r.evaluationStatus == GeJuEvaluationStatus.preFilterRejected)
      .length;

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'matchedCount': matchedCount,
      'totalConditionMissing': totalConditionMissing,
      'totalConditionSetMissing': totalConditionSetMissing,
      'totalEvaluationErrors': totalEvaluationErrors,
      'totalScopeSkipped': totalScopeSkipped,
      'totalPreFilterRejected': totalPreFilterRejected,
      if (evaluationDurationMs != null) 'evaluationDurationMs': evaluationDurationMs,
      'evaluatedAt': evaluatedAt.toIso8601String(),
      'matchedPatterns': matchedPatterns.map((r) => r.toJson()).toList(),
    };
  }
}
