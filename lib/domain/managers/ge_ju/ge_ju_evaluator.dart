import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_variant.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_pre_filter.dart';

/// 格局评估引擎
/// 负责将格局规则列表与命盘输入进行匹配评估
class GeJuEvaluator {
  /// 评估所有规则，返回完整的评估汇总
  ///
  /// [input] 格局判断输入（已构建好的命盘数据）
  /// [rules] 格局规则列表
  /// [onlyMatched] 如果为 true，只返回匹配的结果；false 返回全部结果
  static GeJuEvaluationSummary evaluate({
    required GeJuInput input,
    required List<GeJuRule> rules,
    bool onlyMatched = false,
  }) {
    final results = <GeJuResult>[];

    for (var rule in rules) {
      // 检查 scope 是否适用
      if (!_isScopeApplicable(rule.scope, input)) continue;

      // 评估规则
      final result = evaluateRule(input, rule);

      if (onlyMatched && !result.matched) continue;
      results.add(result);
    }

    return GeJuEvaluationSummary(allResults: results);
  }

  /// 评估单个规则
  static GeJuResult evaluateRule(GeJuInput input, GeJuRule rule) {
    GeJuVariant? targetVariant;

    // 1. 根据偏好流派筛选变体
    for (var variant in rule.variants) {
      // 检查变体的流派列表中是否包含任一用户偏好的流派
      if (variant.schools.any((s) => input.preferredSchools.contains(s))) {
        targetVariant = variant;
        break;
      }
    }

    // 2. 如果没有匹配到偏好流派的变体
    if (targetVariant == null) {
      // 策略：如果没有匹配到偏好流派，
      // 暂时回退到规则层面的“不匹配”结果。
      // 这意味着如果用户只选了“琴堂”，而该规则只有“果老”，则该规则会被视为不匹配（Effective Missing）。
      return GeJuResult.fromRule(rule, matched: false);
    }

    // 3. 评估目标变体
    // 如果变体没有定义条件，视为不匹配
    if (targetVariant.conditions == null) {
      return GeJuResult.fromVariant(
        rule,
        targetVariant,
        matched: false,
      );
    }

    try {
      final matched = targetVariant.conditions!.evaluate(input);
      final conditionDescriptions = <String>[];

      if (matched) {
        conditionDescriptions.add(targetVariant.conditions!.describe());
      }

      return GeJuResult.fromVariant(
        rule,
        targetVariant,
        matched: matched,
        matchedConditionDescriptions: conditionDescriptions,
      );
    } catch (e) {
      // 条件评估出错时，视为未匹配，不中断整体流程
      return GeJuResult.fromVariant(
        rule,
        targetVariant,
        matched: false,
      );
    }
  }

  /// 仅获取匹配的格局列表 (Legacy)
  static List<GeJuResult> getMatchedPatterns({
    required GeJuInput input,
    required List<GeJuRule> rules,
  }) {
    return evaluate(input: input, rules: rules, onlyMatched: true)
        .matchedPatterns;
  }

  // ══════════════════════════════════════════
  // 新模型评估 (ConditionSet-based)
  // ══════════════════════════════════════════

  /// 使用新三实体模型评估格局
  ///
  /// 每个 Rule 关联多个 ConditionSet，按 preferredSchools 选择最合适的方案。
  /// [ruleData] 包含每个 Rule 及其关联的 ConditionSet 和 Annotation 列表。
  static GeJuEvaluationSummary evaluateWithConditionSets({
    required GeJuInput input,
    required List<RuleEvaluationData> ruleData,
    bool onlyMatched = false,
    bool usePreFilter = true,
  }) {
    final results = <GeJuResult>[];

    // 按开关决定是否构建预过滤器
    final preFilter =
        usePreFilter ? GeJuPreFilter.fromInput(input) : null;

    for (var data in ruleData) {
      if (!_isScopeApplicable(data.rule.scope, input)) {
        // scope 不适用：生成 scopeSkipped 结果（而非直接跳过）
        if (!onlyMatched) {
          results.add(GeJuResult(
            patternId: data.rule.id,
            patternName: data.rule.name,
            matched: false,
            jiXiong: JiXiongEnum.PING,
            geJuType: GeJuType.pin,
            description: '',
            source: '',
            scope: data.rule.scope,
            evaluationStatus: GeJuEvaluationStatus.scopeSkipped,
          ));
        }
        continue;
      }

      final result = evaluateRuleWithConditionSets(
        input: input,
        rule: data.rule,
        conditionSets: data.conditionSets,
        annotations: data.annotations,
        preFilter: preFilter,
      );

      if (onlyMatched && !result.matched) continue;
      results.add(result);
    }

    return GeJuEvaluationSummary(allResults: results);
  }

  /// 评估单个 Rule 的 ConditionSet 列表
  static GeJuResult evaluateRuleWithConditionSets({
    required GeJuInput input,
    required GeJuRule rule,
    required List<GeJuConditionSet> conditionSets,
    required List<GeJuAnnotation> annotations,
    GeJuPreFilter? preFilter,
  }) {
    // 1. 按 preferredSchools 筛选 ConditionSet
    GeJuConditionSet? targetCs;
    for (var cs in conditionSets) {
      if (cs.schools != null &&
          cs.schools!.any((s) => input.preferredSchools.contains(s))) {
        targetCs = cs;
        break;
      }
    }

    // 2. 回退：如果没有偏好匹配，取第一个
    targetCs ??= conditionSets.isNotEmpty ? conditionSets.first : null;

    // 3. 找到最相关的 Annotation（同流派优先）
    GeJuAnnotation? bestAnnotation;
    if (targetCs != null && targetCs.relatedAnnotationIds.isNotEmpty) {
      // 先尝试匹配关联的 annotation
      for (var ann in annotations) {
        if (targetCs.relatedAnnotationIds.contains(ann.id)) {
          bestAnnotation = ann;
          break;
        }
      }
    }
    // 回退到同流派的 annotation
    bestAnnotation ??= _findAnnotationBySchools(annotations, input.preferredSchools);
    // 最后回退到第一个 annotation
    bestAnnotation ??= annotations.isNotEmpty ? annotations.first : null;

    // 4. 如果没有 ConditionSet，视为不匹配
    if (targetCs == null) {
      return GeJuResult.fromConditionSet(
        rule,
        GeJuConditionSet(
          id: '',
          ruleId: rule.id,
          label: '',
          authorType: 'built-in',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        annotation: bestAnnotation,
        matched: false,
        evaluationStatus: GeJuEvaluationStatus.conditionSetMissing,
      );
    }

    // 5. 如果没有条件定义，视为不匹配
    if (targetCs.conditions == null) {
      return GeJuResult.fromConditionSet(
        rule,
        targetCs,
        annotation: bestAnnotation,
        matched: false,
        evaluationStatus: GeJuEvaluationStatus.conditionMissing,
      );
    }

    // 6. 预过滤：用三值逻辑快速判定
    if (preFilter != null) {
      final quick = preFilter.quickEvaluate(targetCs.conditions!);
      if (quick == false) {
        // 条件不可能满足 → 直接跳过完整 evaluate
        return GeJuResult.fromConditionSet(
          rule,
          targetCs,
          annotation: bestAnnotation,
          matched: false,
          evaluationStatus: GeJuEvaluationStatus.preFilterRejected,
        );
      }
      if (quick == true) {
        // 条件一定满足 → 直接标记为匹配
        return GeJuResult.fromConditionSet(
          rule,
          targetCs,
          annotation: bestAnnotation,
          matched: true,
          matchedConditionDescriptions: [targetCs.conditions!.describe()],
          evaluationStatus: GeJuEvaluationStatus.matched,
        );
      }
      // quick == null → 无法确定，回退到完整 evaluate
    }

    // 7. 完整评估条件
    try {
      final matched = targetCs.conditions!.evaluate(input);
      final conditionDescriptions = <String>[];

      if (matched) {
        conditionDescriptions.add(targetCs.conditions!.describe());
      }

      return GeJuResult.fromConditionSet(
        rule,
        targetCs,
        annotation: bestAnnotation,
        matched: matched,
        matchedConditionDescriptions: conditionDescriptions,
        evaluationStatus: matched
            ? GeJuEvaluationStatus.matched
            : GeJuEvaluationStatus.unmatched,
      );
    } catch (e) {
      print('GeJu: evaluationError for rule "${rule.name}" (${rule.id}): $e');
      return GeJuResult.fromConditionSet(
        rule,
        targetCs,
        annotation: bestAnnotation,
        matched: false,
        evaluationStatus: GeJuEvaluationStatus.evaluationError,
      );
    }
  }

  /// 按流派偏好查找最合适的 Annotation
  static GeJuAnnotation? _findAnnotationBySchools(
    List<GeJuAnnotation> annotations,
    Set<String> preferredSchools,
  ) {
    for (var ann in annotations) {
      if (ann.schools != null &&
          ann.schools!.any((s) => preferredSchools.contains(s))) {
        return ann;
      }
    }
    return null;
  }

  /// 检查规则的 scope 是否适用当前输入
  static bool _isScopeApplicable(GeJuScope scope, GeJuInput input) {
    switch (scope) {
      case GeJuScope.natal:
        // 命盘格局：始终可评估
        return true;
      case GeJuScope.xingxian:
        // 行限格局：仅在提供了行限数据时可评估
        return input.currentXianGong != null;
      case GeJuScope.both:
        // 通用：始终可评估
        return true;
    }
  }
}

/// 评估数据包：一个 Rule 及其关联的 ConditionSets 和 Annotations
class RuleEvaluationData {
  final GeJuRule rule;
  final List<GeJuConditionSet> conditionSets;
  final List<GeJuAnnotation> annotations;

  const RuleEvaluationData({
    required this.rule,
    required this.conditionSets,
    required this.annotations,
  });
}
