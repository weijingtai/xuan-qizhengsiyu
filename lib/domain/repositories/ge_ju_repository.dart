import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_deletion_record.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_user_preference.dart';

/// 格局仓库接口
/// 定义格局规则的数据访问操作（三实体模型）
abstract class IGeJuRepository {
  // === Rule 操作 ===
  Future<List<GeJuRule>> loadAllRules();
  Future<GeJuRule?> getRuleById(String id);
  Future<void> saveUserRule(GeJuRule rule);
  Future<void> deleteUserRule(String id);
  bool isBuiltInRule(String ruleId);
  Set<String> get builtInRuleIds;

  // === ConditionSet 操作 ===
  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId);
  Future<GeJuConditionSet?> getConditionSetById(String id);
  Future<void> saveUserConditionSet(GeJuConditionSet cs);
  Future<void> deleteUserConditionSet(String id);
  Future<void> deleteUserConditionSetsForRule(String ruleId);

  // === Annotation 操作 ===
  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId);
  Future<GeJuAnnotation?> getAnnotationById(String id);
  Future<void> saveUserAnnotation(GeJuAnnotation ann);
  Future<void> deleteUserAnnotation(String id);
  Future<void> deleteUserAnnotationsForRule(String ruleId);

  // === Preference ===
  Future<GeJuUserPreference> getPreference();
  Future<void> savePreference(GeJuUserPreference pref);

  // === DeletionRecord ===
  Future<void> recordDeletion(GeJuDeletionRecord record);

  // === Cache ===
  void clearCache();

  // === Batch loading (评估管线优化) ===
  Future<Map<String, List<GeJuConditionSet>>> loadAllConditionSetsGrouped();
  Future<Map<String, List<GeJuAnnotation>>> loadAllAnnotationsGrouped();

  // === Legacy 兼容（保留用于迁移和 Evaluator 过渡期） ===
  @Deprecated('Use loadAllRules + getConditionSetsForRule instead')
  Future<List<GeJuRule>> loadBuiltInRules();
  @Deprecated('Use Drift-based user storage instead')
  Future<List<GeJuRule>> loadUserRules();
}
