import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';

/// 格局产品层仓储接口（领域层抽象）
///
/// 由数据层 [GeJuRepositoryAdapter] 实现，供领域服务依赖。
/// 不暴露任何 contract / data 层类型。
abstract class GeJuProductRepository {
  // ── Rule ──

  Future<List<GeJuRule>> loadAllRules();
  Future<GeJuRule?> getRuleById(String id);
  Future<void> saveUserRule(GeJuRule rule);
  Future<void> deleteUserRule(String id);
  bool isBuiltInRule(String ruleId);
  Set<String> get builtInRuleIds;

  // ── ConditionSet ──

  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId);
  Future<GeJuConditionSet?> getConditionSetById(String id);
  Future<void> saveUserConditionSet(GeJuConditionSet cs);
  Future<void> deleteUserConditionSet(String id);
  Future<void> deleteUserConditionSetsForRule(String ruleId);

  // ── Annotation ──

  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId);
  Future<GeJuAnnotation?> getAnnotationById(String id);
  Future<void> saveUserAnnotation(GeJuAnnotation ann);
  Future<void> deleteUserAnnotation(String id);
  Future<void> deleteUserAnnotationsForRule(String ruleId);

  // ── Preference ──

  Future<Map<String, dynamic>> getPreference();
  Future<void> savePreference(Map<String, dynamic> pref);

  // ── DeletionRecord ──

  Future<void> recordDeletion(Map<String, dynamic> record);

  // ── Cache ──

  void clearCache();

  // ── Batch loading ──

  Future<Map<String, List<GeJuConditionSet>>> loadAllConditionSetsGrouped();
  Future<Map<String, List<GeJuAnnotation>>> loadAllAnnotationsGrouped();

  // ── Legacy ──

  Future<List<GeJuRule>> loadBuiltInRules();
  Future<List<GeJuRule>> loadUserRules();
}
