import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_product_repository.dart';

// ═══════════════════════════════════════════════════════
// GeJu Mappers (product ↔ contract)
// ═══════════════════════════════════════════════════════

GeJuRuleContract geJuRuleToContract(GeJuRule rule) {
  return GeJuRuleContract(id: rule.id, name: rule.name, raw: rule.toJson());
}

GeJuRule geJuRuleFromContract(GeJuRuleContract contract) {
  return GeJuRule.fromJson(contract.raw);
}

GeJuAnnotationContract geJuAnnotationToContract(GeJuAnnotation ann) {
  return GeJuAnnotationContract(
    id: ann.id,
    ruleId: ann.ruleId,
    authorType: ann.authorType,
    raw: ann.toJson(),
  );
}

GeJuAnnotation geJuAnnotationFromContract(GeJuAnnotationContract contract) {
  return GeJuAnnotation.fromJson(contract.raw);
}

GeJuConditionSetContract geJuConditionSetToContract(GeJuConditionSet cs) {
  return GeJuConditionSetContract(
    id: cs.id,
    ruleId: cs.ruleId,
    authorType: cs.authorType,
    raw: cs.toJson(),
  );
}

GeJuConditionSet geJuConditionSetFromContract(
    GeJuConditionSetContract contract) {
  return GeJuConditionSet.fromJson(contract.raw);
}

// ═══════════════════════════════════════════════════════
// Adapter: GeJu Repository
// ═══════════════════════════════════════════════════════

/// Wraps the contract-typed [IGeJuRepository] port and presents
/// product-typed methods (GeJuRule ↔ GeJuRuleContract, etc.)
class GeJuRepositoryAdapter implements GeJuProductRepository {
  final IGeJuRepository _port;
  GeJuRepositoryAdapter(this._port);

  @override
  Future<List<GeJuRule>> loadAllRules() async {
    final contracts = await _port.loadAllRules();
    return contracts.map(geJuRuleFromContract).toList();
  }

  @override
  Future<GeJuRule?> getRuleById(String id) async {
    final contract = await _port.getRuleById(id);
    return contract != null ? geJuRuleFromContract(contract) : null;
  }

  @override
  Future<void> saveUserRule(GeJuRule rule) =>
      _port.saveUserRule(geJuRuleToContract(rule));

  @override
  Future<void> deleteUserRule(String id) => _port.deleteUserRule(id);

  @override
  bool isBuiltInRule(String ruleId) => _port.isBuiltInRule(ruleId);

  @override
  Set<String> get builtInRuleIds => _port.builtInRuleIds;

  @override
  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId) async {
    final contracts = await _port.getConditionSetsForRule(ruleId);
    return contracts.map(geJuConditionSetFromContract).toList();
  }

  @override
  Future<GeJuConditionSet?> getConditionSetById(String id) async {
    final contract = await _port.getConditionSetById(id);
    return contract != null ? geJuConditionSetFromContract(contract) : null;
  }

  @override
  Future<void> saveUserConditionSet(GeJuConditionSet cs) =>
      _port.saveUserConditionSet(geJuConditionSetToContract(cs));

  @override
  Future<void> deleteUserConditionSet(String id) =>
      _port.deleteUserConditionSet(id);

  @override
  Future<void> deleteUserConditionSetsForRule(String ruleId) =>
      _port.deleteUserConditionSetsForRule(ruleId);

  @override
  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId) async {
    final contracts = await _port.getAnnotationsForRule(ruleId);
    return contracts.map(geJuAnnotationFromContract).toList();
  }

  @override
  Future<GeJuAnnotation?> getAnnotationById(String id) async {
    final contract = await _port.getAnnotationById(id);
    return contract != null ? geJuAnnotationFromContract(contract) : null;
  }

  @override
  Future<void> saveUserAnnotation(GeJuAnnotation ann) =>
      _port.saveUserAnnotation(geJuAnnotationToContract(ann));

  @override
  Future<void> deleteUserAnnotation(String id) =>
      _port.deleteUserAnnotation(id);

  @override
  Future<void> deleteUserAnnotationsForRule(String ruleId) =>
      _port.deleteUserAnnotationsForRule(ruleId);

  @override
  Future<Map<String, dynamic>> getPreference() => _port.getPreference();

  @override
  Future<void> savePreference(Map<String, dynamic> pref) =>
      _port.savePreference(pref);

  @override
  Future<void> recordDeletion(Map<String, dynamic> record) =>
      _port.recordDeletion(record);

  @override
  void clearCache() => _port.clearCache();

  @override
  Future<Map<String, List<GeJuConditionSet>>>
      loadAllConditionSetsGrouped() async {
    final contractMap = await _port.loadAllConditionSetsGrouped();
    return contractMap.map((key, value) =>
        MapEntry(key, value.map(geJuConditionSetFromContract).toList()));
  }

  @override
  Future<Map<String, List<GeJuAnnotation>>>
      loadAllAnnotationsGrouped() async {
    final contractMap = await _port.loadAllAnnotationsGrouped();
    return contractMap.map((key, value) =>
        MapEntry(key, value.map(geJuAnnotationFromContract).toList()));
  }

  static final _ctx = RequestContext(scopeUid: 'local-anonymous');

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async {
    final result = await _port.query(
        {"type": "builtin"}, PageRequest(limit: 100), _ctx);
    return switch (result) {
      Ok(:final value) => value.items.map(geJuRuleFromContract).toList(),
      Err(:final error) => throw error,
    };
  }

  @override
  Future<List<GeJuRule>> loadUserRules() async {
    final result = await _port.query(
        {"type": "user"}, PageRequest(limit: 100), _ctx);
    return switch (result) {
      Ok(:final value) => value.items.map(geJuRuleFromContract).toList(),
      Err(:final error) => throw error,
    };
  }
}
