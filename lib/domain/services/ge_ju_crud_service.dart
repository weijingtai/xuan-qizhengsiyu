import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_validation.dart';
import 'package:uuid/uuid.dart';

/// 格局 CRUD 服务
/// 提供格局规则的创建、读取、更新、删除以及搜索、验证、导入导出功能
class GeJuCrudService {
  final IGeJuRepository _repository;
  static const _uuid = Uuid();

  GeJuCrudService({required IGeJuRepository repository})
      : _repository = repository;

  // ========== CRUD 操作 ==========

  /// 创建新格局
  Future<GeJuRule> createRule(GeJuRuleCreateParams params) async {
    final rule = GeJuRule(
      id: 'user_${_uuid.v4()}',
      name: params.name,
      className: params.className,
      books: params.books ?? '',
      description: params.description,
      source: params.source ?? '',
      jiXiong: params.jiXiong,
      geJuType: params.geJuType,
      scope: params.scope,
      conditions: params.conditions,
    );

    // 验证
    final validation = validateRule(rule);
    if (!validation.isValid) {
      throw RuleValidationError(validation.errors);
    }

    await _repository.saveUserRule(rule);
    return rule;
  }

  /// 获取单个格局详情
  Future<GeJuRule?> getRule(String ruleId) async {
    return await _repository.getRuleById(ruleId);
  }

  /// 获取所有格局
  Future<List<GeJuRule>> getAllRules() async {
    return await _repository.loadAllRules();
  }

  /// 获取内置格局
  Future<List<GeJuRule>> getBuiltInRules() async {
    return await _repository.loadBuiltInRules();
  }

  /// 获取用户格局
  Future<List<GeJuRule>> getUserRules() async {
    return await _repository.loadUserRules();
  }

  /// 更新格局
  Future<void> updateRule(GeJuRule rule) async {
    if (_repository.isBuiltInRule(rule.id)) {
      throw BuiltInRuleModificationError(rule.id);
    }

    // 验证
    final validation = validateRule(rule);
    if (!validation.isValid) {
      throw RuleValidationError(validation.errors);
    }

    await _repository.saveUserRule(rule);
  }

  /// 删除格局
  Future<void> deleteRule(String ruleId) async {
    if (_repository.isBuiltInRule(ruleId)) {
      throw BuiltInRuleModificationError(ruleId);
    }

    await _repository.deleteUserRule(ruleId);
  }

  // ========== 查询与筛选 ==========

  /// 按关键词搜索
  ///
  /// 搜索 name、description、className、books 字段
  /// 关键词不区分大小写
  Future<List<GeJuRule>> searchRules(String keyword) async {
    final allRules = await getAllRules();
    if (keyword.trim().isEmpty) return allRules;

    final lowerKeyword = keyword.toLowerCase();
    return allRules.where((rule) {
      return rule.name.toLowerCase().contains(lowerKeyword) ||
          rule.description.toLowerCase().contains(lowerKeyword) ||
          rule.className.toLowerCase().contains(lowerKeyword) ||
          rule.books.toLowerCase().contains(lowerKeyword) ||
          rule.source.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// 按分类筛选
  Future<List<GeJuRule>> filterByCategory(String category) async {
    final allRules = await getAllRules();
    return allRules.where((rule) => rule.className == category).toList();
  }

  /// 按吉凶筛选
  Future<List<GeJuRule>> filterByJiXiong(JiXiongEnum jiXiong) async {
    final allRules = await getAllRules();
    return allRules.where((rule) => rule.jiXiong == jiXiong).toList();
  }

  /// 按格局类型筛选
  Future<List<GeJuRule>> filterByType(GeJuType type) async {
    final allRules = await getAllRules();
    return allRules.where((rule) => rule.geJuType == type).toList();
  }

  /// 按适用范围筛选
  Future<List<GeJuRule>> filterByScope(GeJuScope scope) async {
    final allRules = await getAllRules();
    return allRules.where((rule) => rule.scope == scope).toList();
  }

  /// 获取所有分类列表（去重）
  Future<List<String>> getCategories() async {
    final allRules = await getAllRules();
    final categories = allRules.map((r) => r.className).toSet().toList();
    categories.sort();
    return categories;
  }

  // ========== 验证 ==========

  /// 验证格局规则的有效性
  ValidationResult validateRule(GeJuRule rule) {
    final errors = <String>[];
    final warnings = <String>[];

    // 名称不为空
    if (rule.name.trim().isEmpty) {
      errors.add('格局名称不能为空');
    }

    // 分类不为空
    if (rule.className.trim().isEmpty) {
      errors.add('格局分类不能为空');
    }

    // 描述不为空
    if (rule.description.trim().isEmpty) {
      warnings.add('建议填写格局描述');
    }

    // 如果有条件，验证条件结构
    if (rule.conditions != null) {
      final conditionValidation = validateCondition(rule.conditions!);
      errors.addAll(conditionValidation.errors);
      warnings.addAll(conditionValidation.warnings);
    } else {
      warnings.add('未设置判断条件，该格局将无法进行匹配');
    }

    return errors.isEmpty
        ? ValidationResult.valid(warnings: warnings)
        : ValidationResult.invalid(errors: errors, warnings: warnings);
  }

  /// 验证条件的有效性
  ValidationResult validateCondition(GeJuCondition condition) {
    final errors = <String>[];
    final warnings = <String>[];

    if (condition is AndCondition) {
      if (condition.conditions.isEmpty) {
        errors.add('AND 条件组至少需要一个子条件');
      }
      for (final child in condition.conditions) {
        final result = validateCondition(child);
        errors.addAll(result.errors);
        warnings.addAll(result.warnings);
      }
    } else if (condition is OrCondition) {
      if (condition.conditions.isEmpty) {
        errors.add('OR 条件组至少需要一个子条件');
      }
      if (condition.conditions.length == 1) {
        warnings.add('OR 条件组只有一个子条件，可以简化');
      }
      for (final child in condition.conditions) {
        final result = validateCondition(child);
        errors.addAll(result.errors);
        warnings.addAll(result.warnings);
      }
    } else if (condition is NotCondition) {
      final result = validateCondition(condition.condition);
      errors.addAll(result.errors);
      warnings.addAll(result.warnings);
    }
    // 叶子条件通过 describe() 检查，暂不做深层参数验证

    return errors.isEmpty
        ? ValidationResult.valid(warnings: warnings)
        : ValidationResult.invalid(errors: errors, warnings: warnings);
  }

  // ========== 导入导出 ==========

  /// 导出选中的格局
  Future<String> exportRules(List<String> ruleIds) async {
    final allRules = await getAllRules();
    final selectedRules =
        allRules.where((rule) => ruleIds.contains(rule.id)).toList();

    if (selectedRules.isEmpty) {
      throw RuleNotFoundError(ruleIds.join(', '));
    }

    return await _repository.exportRules(selectedRules);
  }

  /// 导出全部规则
  Future<String> exportAllRules() async {
    final allRules = await getAllRules();
    return await _repository.exportRules(allRules);
  }

  /// 从 JSON 导入格局
  Future<ImportResult> importRulesFromJson(String jsonContent) async {
    try {
      final importedRules = await _repository.importRules(jsonContent);

      int successCount = 0;
      int failedCount = 0;
      final savedRules = <GeJuRule>[];
      final errors = <String>[];

      for (final rule in importedRules) {
        try {
          final validation = validateRule(rule);
          if (validation.isValid) {
            await _repository.saveUserRule(rule);
            savedRules.add(rule);
            successCount++;
          } else {
            failedCount++;
            errors.add('规则 "${rule.name}": ${validation.errors.join(", ")}');
          }
        } catch (e) {
          failedCount++;
          errors.add('规则 "${rule.name}": $e');
        }
      }

      return ImportResult(
        successCount: successCount,
        failedCount: failedCount,
        importedRules: savedRules,
        errors: errors,
      );
    } catch (e) {
      if (e is GeJuError) rethrow;
      throw RuleImportError('导入失败', details: e.toString());
    }
  }

  /// 复制格局
  ///
  /// 基于现有格局创建副本，生成新 UUID，名称加 "(副本)" 后缀
  Future<GeJuRule> duplicateRule(String ruleId) async {
    final original = await getRule(ruleId);
    if (original == null) {
      throw RuleNotFoundError(ruleId);
    }

    final duplicate = GeJuRule(
      id: 'user_${_uuid.v4()}',
      name: '${original.name} (副本)',
      className: original.className,
      books: original.books,
      description: original.description,
      source: original.source,
      jiXiong: original.jiXiong,
      geJuType: original.geJuType,
      scope: original.scope,
      conditions: original.conditions,
      coordinateSystem: original.coordinateSystem,
    );

    await _repository.saveUserRule(duplicate);
    return duplicate;
  }

  /// 判断规则是否为内置
  bool isBuiltInRule(String ruleId) {
    return _repository.isBuiltInRule(ruleId);
  }

  /// 清除缓存并强制重新加载
  void clearCache() {
    _repository.clearCache();
  }
}
