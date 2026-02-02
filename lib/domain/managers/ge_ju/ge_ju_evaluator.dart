import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';

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
    // 如果没有条件定义，视为未匹配
    if (rule.conditions == null) {
      return GeJuResult.fromRule(rule, matched: false);
    }

    try {
      final matched = rule.conditions!.evaluate(input);
      final conditionDescriptions = <String>[];

      if (matched) {
        conditionDescriptions.add(rule.conditions!.describe());
      }

      return GeJuResult.fromRule(
        rule,
        matched: matched,
        matchedConditionDescriptions: conditionDescriptions,
      );
    } catch (e) {
      // 条件评估出错时，视为未匹配，不中断整体流程
      return GeJuResult.fromRule(rule, matched: false);
    }
  }

  /// 仅获取匹配的格局列表
  static List<GeJuResult> getMatchedPatterns({
    required GeJuInput input,
    required List<GeJuRule> rules,
  }) {
    return evaluate(input: input, rules: rules, onlyMatched: true)
        .matchedPatterns;
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
