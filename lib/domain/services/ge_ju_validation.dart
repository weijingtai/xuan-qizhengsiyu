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

  factory ValidationResult.valid({List<String> warnings = const []}) {
    return ValidationResult(isValid: true, warnings: warnings);
  }

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

/// 创建格局规则的参数（薄锚点）
class GeJuRuleCreateParams {
  final String name;
  final GeJuScope scope;
  final String? disambiguationNote;

  const GeJuRuleCreateParams({
    required this.name,
    required this.scope,
    this.disambiguationNote,
  });
}

/// 创建判断方案的参数
class ConditionSetCreateParams {
  final String ruleId;
  final String label;
  final GeJuCondition? conditions;
  final String? changeNote;
  final List<String>? schools;

  const ConditionSetCreateParams({
    required this.ruleId,
    required this.label,
    this.conditions,
    this.changeNote,
    this.schools,
  });
}

/// 创建注解的参数
class AnnotationCreateParams {
  final String ruleId;
  final String? description;
  final JiXiongEnum? jiXiong;
  final GeJuType? geJuType;
  final String? className;
  final String? books;
  final String? sourceSection;
  final List<String>? schools;

  const AnnotationCreateParams({
    required this.ruleId,
    this.description,
    this.jiXiong,
    this.geJuType,
    this.className,
    this.books,
    this.sourceSection,
    this.schools,
  });
}

/// "另存为"参数（包含 Rule + CS + Ann 的完整字段）
class GeJuRuleSaveAsParams {
  // Rule fields
  final String name;
  final GeJuScope scope;
  final String? disambiguationNote;

  // Annotation fields
  final String? description;
  final JiXiongEnum? jiXiong;
  final GeJuType? geJuType;
  final String? className;
  final String? books;
  final String? sourceSection;
  final List<String>? annotationSchools;

  // ConditionSet fields
  final String csLabel;
  final GeJuCondition? conditions;
  final String? changeNote;
  final String? derivedFrom;
  final List<String>? conditionSetSchools;

  const GeJuRuleSaveAsParams({
    required this.name,
    required this.scope,
    this.disambiguationNote,
    this.description,
    this.jiXiong,
    this.geJuType,
    this.className,
    this.books,
    this.sourceSection,
    this.annotationSchools,
    required this.csLabel,
    this.conditions,
    this.changeNote,
    this.derivedFrom,
    this.conditionSetSchools,
  });
}
