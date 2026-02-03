import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';

/// 规则验证结果
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// 验证通过的结果
  factory ValidationResult.valid({List<String> warnings = const []}) {
    return ValidationResult(isValid: true, warnings: warnings);
  }

  /// 验证失败的结果
  factory ValidationResult.invalid({
    required List<String> errors,
    List<String> warnings = const [],
  }) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 合并两个验证结果
  ValidationResult merge(ValidationResult other) {
    return ValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      warnings: [...warnings, ...other.warnings],
    );
  }

  @override
  String toString() {
    if (isValid && warnings.isEmpty) return 'ValidationResult: valid';
    final parts = <String>[];
    if (!isValid) parts.add('errors: ${errors.join(", ")}');
    if (warnings.isNotEmpty) parts.add('warnings: ${warnings.join(", ")}');
    return 'ValidationResult: ${parts.join("; ")}';
  }
}

/// 导入结果
class ImportResult {
  final int successCount;
  final int failedCount;
  final List<GeJuRule> importedRules;
  final List<String> errors;

  const ImportResult({
    required this.successCount,
    required this.failedCount,
    required this.importedRules,
    this.errors = const [],
  });

  bool get hasErrors => failedCount > 0;
  int get totalCount => successCount + failedCount;

  @override
  String toString() {
    return 'ImportResult: $successCount/$totalCount 成功, $failedCount 失败';
  }
}

/// 创建格局规则的参数
class GeJuRuleCreateParams {
  final String name;
  final String className;
  final String? books;
  final String description;
  final String? source;
  final JiXiongEnum jiXiong;
  final GeJuType geJuType;
  final GeJuScope scope;
  final GeJuCondition? conditions;

  const GeJuRuleCreateParams({
    required this.name,
    required this.className,
    this.books,
    required this.description,
    this.source,
    required this.jiXiong,
    required this.geJuType,
    required this.scope,
    this.conditions,
  });
}
