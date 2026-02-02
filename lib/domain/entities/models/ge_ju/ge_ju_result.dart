import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'ge_ju_rule.dart';

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
  });

  /// 从 GeJuRule 和匹配状态创建结果
  factory GeJuResult.fromRule(
    GeJuRule rule, {
    required bool matched,
    List<String> matchedConditionDescriptions = const [],
  }) {
    return GeJuResult(
      patternId: rule.id,
      patternName: rule.name,
      matched: matched,
      jiXiong: rule.jiXiong,
      geJuType: rule.geJuType,
      description: rule.description,
      source: rule.source,
      scope: rule.scope,
      matchedConditionDescriptions: matchedConditionDescriptions,
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

  GeJuEvaluationSummary({
    required this.allResults,
    DateTime? evaluatedAt,
  }) : evaluatedAt = evaluatedAt ?? DateTime.now();

  /// 获取所有匹配的格局
  List<GeJuResult> get matchedPatterns =>
      allResults.where((r) => r.matched).toList();

  /// 获取所有吉格局
  List<GeJuResult> get matchedAuspiciousPatterns =>
      matchedPatterns.where((r) => r.jiXiong == JiXiongEnum.JI).toList();

  /// 获取所有凶格局
  List<GeJuResult> get matchedInauspiciousPatterns =>
      matchedPatterns.where((r) => r.jiXiong == JiXiongEnum.XIONG).toList();

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

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'matchedCount': matchedCount,
      'evaluatedAt': evaluatedAt.toIso8601String(),
      'matchedPatterns': matchedPatterns.map((r) => r.toJson()).toList(),
    };
  }
}
