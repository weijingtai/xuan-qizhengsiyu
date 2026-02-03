/// 格局管理相关错误类型

/// 格局错误基类
abstract class GeJuError implements Exception {
  final String message;
  final String? details;

  GeJuError(this.message, {this.details});

  @override
  String toString() {
    if (details != null) {
      return '$runtimeType: $message\n详情: $details';
    }
    return '$runtimeType: $message';
  }
}

/// 规则未找到错误
class RuleNotFoundError extends GeJuError {
  final String ruleId;

  RuleNotFoundError(this.ruleId) : super('格局不存在: $ruleId');
}

/// 规则验证错误
class RuleValidationError extends GeJuError {
  final List<String> errors;

  RuleValidationError(this.errors)
      : super('格局验证失败', details: errors.join('\n'));

  /// 是否有验证错误
  bool get hasErrors => errors.isNotEmpty;
}

/// 内置规则修改错误
class BuiltInRuleModificationError extends GeJuError {
  final String ruleId;

  BuiltInRuleModificationError(this.ruleId)
      : super('内置格局不可修改: $ruleId');
}

/// 规则存储错误
class RuleStorageError extends GeJuError {
  RuleStorageError(String message, {String? details})
      : super('存储错误: $message', details: details);
}

/// 规则导入错误
class RuleImportError extends GeJuError {
  final int? lineNumber;
  final String? ruleId;

  RuleImportError(
    String message, {
    this.lineNumber,
    this.ruleId,
    String? details,
  }) : super(
          lineNumber != null
              ? '导入错误 (行 $lineNumber): $message'
              : (ruleId != null ? '导入错误 (规则 $ruleId): $message' : '导入错误: $message'),
          details: details,
        );
}

/// 规则解析错误
class RuleParseError extends GeJuError {
  final String? source;

  RuleParseError(String message, {this.source, String? details})
      : super('解析错误: $message', details: details);
}

/// 条件配置错误
class ConditionConfigError extends GeJuError {
  final String conditionType;

  ConditionConfigError(this.conditionType, String message)
      : super('条件配置错误 ($conditionType): $message');
}
