import 'dart:convert';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';

/// 格局规则解析器
/// 负责将 JSON 数据解析为 GeJuRule 对象及其嵌套条件
class GeJuRuleParser {
  /// 解析 JSON 字符串列表为格局规则列表
  /// [jsonContent] 必须是 JSON 数组字符串
  static List<GeJuRule> parseRules(String jsonContent) {
    if (jsonContent.trim().isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(jsonContent);
    return jsonList.map((json) {
      if (json is! Map<String, dynamic>) {
        throw FormatException(
            "Expected JSON object in rule list, got ${json.runtimeType}");
      }
      return parseRule(json);
    }).toList();
  }

  /// 解析单个规则 JSON Map
  static GeJuRule parseRule(Map<String, dynamic> json) {
    try {
      return GeJuRule.fromJson(json);
    } catch (e) {
      // 可以在此处添加更详细的错误上下文
      final id = json['id'] ?? 'unknown';
      throw FormatException("Failed to parse rule '$id': $e");
    }
  }

  /// 注册自定义条件解析器（扩展点）
  /// 如果将来有特殊的条件解析需求，可以在此添加逻辑
  /// 目前主要依赖 GeJuCondition.fromJson 的分发机制
}
