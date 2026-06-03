import 'dart:convert';

import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_deletion_record.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_user_preference.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_validation.dart';
import 'package:uuid/uuid.dart';

/// 格局 CRUD 服务（三实体模型）
///
/// 提供 Rule/ConditionSet/Annotation 的创建、读取、更新、删除
/// 以及 Fork、Duplicate、SaveAs 等复合操作
class GeJuCrudService {
  final IGeJuRepository _repository;
  static const _uuid = Uuid();

  GeJuCrudService({required IGeJuRepository repository})
      : _repository = repository;

  // ══════════════════════════════════════════
  // Rule CRUD
  // ══════════════════════════════════════════

  /// 创建新格局（薄锚点）
  Future<GeJuRule> createRule(GeJuRuleCreateParams params) async {
    final now = DateTime.now();
    final rule = GeJuRule(
      id: 'user_${_uuid.v4()}',
      name: params.name,
      scope: params.scope,
      disambiguationNote: params.disambiguationNote,
      authorType: 'user',
      createdAt: now,
      updatedAt: now,
    );

    final validation = validateRuleName(rule.name);
    if (!validation.isValid) {
      throw RuleValidationError(validation.errors);
    }

    await _repository.saveUserRule(rule);
    return rule;
  }

  /// 获取单个格局详情
  Future<GeJuRule?> getRule(String id) async {
    return await _repository.getRuleById(id);
  }

  /// 获取所有格局
  Future<List<GeJuRule>> getAllRules() async {
    return await _repository.loadAllRules();
  }

  /// 更新格局
  Future<void> updateRule(GeJuRule rule) async {
    if (_repository.isBuiltInRule(rule.id)) {
      throw BuiltInRuleModificationError(rule.id);
    }
    final validation = validateRuleName(rule.name);
    if (!validation.isValid) {
      throw RuleValidationError(validation.errors);
    }
    await _repository.saveUserRule(rule);
  }

  /// 删除格局（级联删除用户 CS + Ann）
  Future<void> deleteRule(String id) async {
    if (_repository.isBuiltInRule(id)) {
      throw BuiltInRuleModificationError(id);
    }
    // 级联删除
    await _repository.deleteUserConditionSetsForRule(id);
    await _repository.deleteUserAnnotationsForRule(id);
    await _repository.deleteUserRule(id);
  }

  // ══════════════════════════════════════════
  // ConditionSet 操作
  // ══════════════════════════════════════════

  /// 创建判断方案
  Future<GeJuConditionSet> createConditionSet(ConditionSetCreateParams params) async {
    final now = DateTime.now();
    final cs = GeJuConditionSet(
      id: 'user_${_uuid.v4()}',
      ruleId: params.ruleId,
      label: params.label,
      schools: params.schools,
      authorType: 'user',
      conditions: params.conditions,
      changeNote: params.changeNote,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.saveUserConditionSet(cs);
    return cs;
  }

  /// 获取某格局的所有判断方案
  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId) async {
    return await _repository.getConditionSetsForRule(ruleId);
  }

  /// 获取某个判断方案
  Future<GeJuConditionSet?> getConditionSetById(String id) async {
    return await _repository.getConditionSetById(id);
  }

  /// 更新判断方案
  Future<void> updateConditionSet(GeJuConditionSet cs) async {
    if (cs.isBuiltIn) {
      throw BuiltInRuleModificationError(cs.id);
    }
    await _repository.saveUserConditionSet(cs);
  }

  /// 删除判断方案
  Future<void> deleteConditionSet(String id) async {
    await _repository.deleteUserConditionSet(id);
  }

  /// Fork: 基于已有方案深拷贝创建用户自己的独立方案
  Future<GeJuConditionSet> forkConditionSet(String originalId) async {
    final original = await _repository.getConditionSetById(originalId);
    if (original == null) {
      throw ConditionSetNotFoundError(originalId);
    }

    final now = DateTime.now();
    // Deep copy conditions by serializing/deserializing
    GeJuCondition? copiedConditions;
    if (original.conditions != null) {
      final json = original.conditions!.toJson();
      copiedConditions = GeJuCondition.fromJson(json);
    }

    final forked = GeJuConditionSet(
      id: 'user_${_uuid.v4()}',
      ruleId: original.ruleId,
      label: '基于「${original.label}」的修改',
      schools: original.schools != null ? List.from(original.schools!) : null,
      source: original.source,
      authorType: 'user',
      conditions: copiedConditions,
      derivedFrom: original.id,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.saveUserConditionSet(forked);
    return forked;
  }

  // ══════════════════════════════════════════
  // Annotation 操作
  // ══════════════════════════════════════════

  /// 创建注解
  Future<GeJuAnnotation> createAnnotation(AnnotationCreateParams params) async {
    final now = DateTime.now();

    GeJuSource? source;
    if (params.books != null && params.books!.isNotEmpty) {
      source = GeJuSource(
        bookName: params.books!,
        school: params.schools?.isNotEmpty == true ? params.schools!.first : 'user',
        section: params.sourceSection,
      );
    }

    final ann = GeJuAnnotation(
      id: 'user_${_uuid.v4()}',
      ruleId: params.ruleId,
      schools: params.schools,
      source: source,
      authorType: 'user',
      description: params.description,
      jiXiong: params.jiXiong,
      geJuType: params.geJuType,
      className: params.className,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.saveUserAnnotation(ann);
    return ann;
  }

  /// 获取某格局的所有注解
  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId) async {
    return await _repository.getAnnotationsForRule(ruleId);
  }

  /// 更新注解
  Future<void> updateAnnotation(GeJuAnnotation ann) async {
    if (ann.isBuiltIn) {
      throw BuiltInRuleModificationError(ann.id);
    }
    await _repository.saveUserAnnotation(ann);
  }

  /// 删除注解
  Future<void> deleteAnnotation(String id) async {
    await _repository.deleteUserAnnotation(id);
  }

  // ══════════════════════════════════════════
  // 复合操作
  // ══════════════════════════════════════════

  /// 复制格局（Rule + 所有 user CS + Ann）
  Future<GeJuRule> duplicateRule(String ruleId) async {
    final original = await getRule(ruleId);
    if (original == null) {
      throw RuleNotFoundError(ruleId);
    }

    final now = DateTime.now();
    final newRuleId = 'user_${_uuid.v4()}';

    // 1. 创建新 Rule
    final newRule = GeJuRule(
      id: newRuleId,
      name: '${original.name} (副本)',
      aliases: original.aliases,
      disambiguationNote: original.disambiguationNote,
      scope: original.scope,
      coordinateSystem: original.coordinateSystem,
      authorType: 'user',
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveUserRule(newRule);

    // 2. 复制 ConditionSets
    final conditionSets = await _repository.getConditionSetsForRule(ruleId);
    for (final cs in conditionSets) {
      // Deep copy conditions
      GeJuCondition? copiedConditions;
      if (cs.conditions != null) {
        copiedConditions = GeJuCondition.fromJson(cs.conditions!.toJson());
      }

      final newCs = GeJuConditionSet(
        id: 'user_${_uuid.v4()}',
        ruleId: newRuleId,
        label: cs.label,
        schools: cs.schools != null ? List.from(cs.schools!) : null,
        source: cs.source,
        authorType: 'user',
        conditions: copiedConditions,
        derivedFrom: cs.id,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.saveUserConditionSet(newCs);
    }

    // 3. 复制 Annotations（仅 user 的，内置保留在原 rule 上）
    final annotations = await _repository.getAnnotationsForRule(ruleId);
    for (final ann in annotations) {
      if (ann.isUser) {
        final newAnn = ann.copyWith(
          id: 'user_${_uuid.v4()}',
          ruleId: newRuleId,
          createdAt: now,
          updatedAt: now,
        );
        await _repository.saveUserAnnotation(newAnn);
      }
    }

    return newRule;
  }

  /// 另存为（从编辑器状态创建全新格局）
  Future<GeJuRule> saveRuleAs(GeJuRuleSaveAsParams params) async {
    final now = DateTime.now();
    final newRuleId = 'user_${_uuid.v4()}';

    // 1. 创建 Rule
    final rule = GeJuRule(
      id: newRuleId,
      name: params.name,
      scope: params.scope,
      disambiguationNote: params.disambiguationNote,
      authorType: 'user',
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveUserRule(rule);

    // 2. 创建 Annotation
    GeJuSource? source;
    if (params.books != null && params.books!.isNotEmpty) {
      source = GeJuSource(
        bookName: params.books!,
        school: 'user',
        section: params.sourceSection,
      );
    }

    final ann = GeJuAnnotation(
      id: 'user_${_uuid.v4()}',
      ruleId: newRuleId,
      schools: params.annotationSchools,
      authorType: 'user',
      description: params.description,
      jiXiong: params.jiXiong,
      geJuType: params.geJuType,
      className: params.className,
      source: source,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveUserAnnotation(ann);

    // 3. 创建 ConditionSet
    final cs = GeJuConditionSet(
      id: 'user_${_uuid.v4()}',
      ruleId: newRuleId,
      label: params.csLabel,
      schools: params.conditionSetSchools,
      authorType: 'user',
      conditions: params.conditions,
      derivedFrom: params.derivedFrom,
      changeNote: params.changeNote,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveUserConditionSet(cs);

    return rule;
  }

  // ══════════════════════════════════════════
  // Search / Filter
  // ══════════════════════════════════════════

  /// 按关键词搜索（Rule name + aliases + Annotation description/className）
  Future<List<GeJuRule>> searchRules(String keyword) async {
    final allRules = await getAllRules();
    if (keyword.trim().isEmpty) return allRules;

    final lowerKeyword = keyword.toLowerCase();
    return allRules.where((rule) {
      // Search in rule name
      if (rule.name.toLowerCase().contains(lowerKeyword)) return true;
      // Search in aliases
      for (final alias in rule.aliases) {
        if (alias.name.toLowerCase().contains(lowerKeyword)) return true;
      }
      // Legacy: also check deprecated getters for transition period
      // ignore: deprecated_member_use_from_same_package
      if (rule.description.toLowerCase().contains(lowerKeyword)) return true;
      // ignore: deprecated_member_use_from_same_package
      if (rule.className.toLowerCase().contains(lowerKeyword)) return true;
      return false;
    }).toList();
  }

  /// 按分类筛选
  Future<List<GeJuRule>> filterByCategory(String category) async {
    final allRules = await getAllRules();
    return allRules.where((rule) {
      // ignore: deprecated_member_use_from_same_package
      return rule.className == category;
    }).toList();
  }

  // ══════════════════════════════════════════
  // Preference
  // ══════════════════════════════════════════

  Future<GeJuUserPreference> getPreference() async {
    return await _repository.getPreference();
  }

  Future<void> savePreference(GeJuUserPreference pref) async {
    await _repository.savePreference(pref);
  }

  // ══════════════════════════════════════════
  // Validation
  // ══════════════════════════════════════════

  /// 验证规则名称
  ValidationResult validateRuleName(String name) {
    final errors = <String>[];
    if (name.trim().isEmpty) {
      errors.add('格局名称不能为空');
    }
    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors: errors);
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

    return errors.isEmpty
        ? ValidationResult.valid(warnings: warnings)
        : ValidationResult.invalid(errors: errors, warnings: warnings);
  }

  // ══════════════════════════════════════════
  // Utility
  // ══════════════════════════════════════════

  bool isBuiltInRule(String ruleId) {
    return _repository.isBuiltInRule(ruleId);
  }

  void clearCache() {
    _repository.clearCache();
  }
}
