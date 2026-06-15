import 'dart:convert';

import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/pan_entity.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_product_repository.dart';

// ═══════════════════════════════════════════════════════
// ShenSha Mappers (contract → product)
// ═══════════════════════════════════════════════════════

List<TianGanShenSha> tianGanShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => TianGanShenSha.fromJson(c.raw)).toList();
}

List<YearDiZhiShenSha> yearDiZhiShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => YearDiZhiShenSha.fromJson(c.raw)).toList();
}

List<MonthDiZhiShenSha> monthDiZhiShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => MonthDiZhiShenSha.fromJson(c.raw)).toList();
}

List<GanZhiShenSha> ganZhiShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => GanZhiShenSha.fromJson(c.raw)).toList();
}

List<BundledShenSha> bundledShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => BundledShenSha.fromJson(c.raw)).toList();
}

List<OtherShenSha> otherShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => OtherShenSha.fromJson(c.raw)).toList();
}

// ═══════════════════════════════════════════════════════
// HuaYao Mappers (contract → product)
// ═══════════════════════════════════════════════════════

List<TianGanHuaYao> tianGanHuaYaoFromContracts(
    List<HuaYaoRecordContract> contracts) {
  return contracts.map((c) => TianGanHuaYao.fromJson(c.raw)).toList();
}

List<DiZhiHuaYao> diZhiHuaYaoFromContracts(
    List<HuaYaoRecordContract> contracts) {
  return contracts.map((c) => DiZhiHuaYao.fromJson(c.raw)).toList();
}

List<OthersHuaYao> othersHuaYaoFromContracts(
    List<HuaYaoRecordContract> contracts) {
  return contracts.map((c) => OthersHuaYao.fromJson(c.raw)).toList();
}

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

GeJuSchoolContract geJuSchoolToContract(GeJuSchool school) {
  return GeJuSchoolContract(
    id: school.id,
    name: school.name,
    brief: school.brief,
    features: school.features,
  );
}

GeJuSchool geJuSchoolFromContract(GeJuSchoolContract contract) {
  return GeJuSchool(
    id: contract.id,
    name: contract.name,
    brief: contract.brief,
    features: contract.features,
  );
}

// ═══════════════════════════════════════════════════════
// Pan Mappers (product ↔ contract)
// ═══════════════════════════════════════════════════════

QiZhengSiYuPanContract panEntityToContract(QiZhengSiYuPanEntity entity) {
  return entity.toContract();
}

QiZhengSiYuPanEntity panEntityFromContract(QiZhengSiYuPanContract contract) {
  return QiZhengSiYuPanEntity.fromContract(contract);
}

// ═══════════════════════════════════════════════════════
// Adapter: ShenSha Repository
// ═══════════════════════════════════════════════════════

/// Wraps [QiZhengShenShaRepository] (contract port) and presents
/// the product-typed [ShenShaRepository] interface.
class ShenShaRepositoryAdapter implements ShenShaRepository {
  final QiZhengShenShaRepository _port;
  ShenShaRepositoryAdapter(this._port);

  @override
  Future<List<TianGanShenSha>> getTianGanShenSha() async =>
      tianGanShenShaFromContracts(await _port.getTianGanShenSha());

  @override
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async =>
      yearDiZhiShenShaFromContracts(await _port.getYearDiZhiShenSha());

  @override
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async =>
      monthDiZhiShenShaFromContracts(await _port.getMonthDiZhiShenSha());

  @override
  Future<List<GanZhiShenSha>> getGanZhiShenSha() async =>
      ganZhiShenShaFromContracts(await _port.getGanZhiShenSha());

  @override
  Future<List<BundledShenSha>> getBundledShenSha() async =>
      bundledShenShaFromContracts(await _port.getBundledShenSha());

  @override
  Future<List<OtherShenSha>> getOtherShenSha() async =>
      otherShenShaFromContracts(await _port.getOtherShenSha());
}

// ═══════════════════════════════════════════════════════
// Adapter: HuaYao Repository
// ═══════════════════════════════════════════════════════

/// Wraps [QiZhengHuaYaoRepository] (contract port) and presents
/// the product-typed [HuaYaoRepository] interface.
class HuaYaoRepositoryAdapter implements HuaYaoRepository {
  final QiZhengHuaYaoRepository _port;
  HuaYaoRepositoryAdapter(this._port);

  @override
  Future<List<TianGanHuaYao>> getTianGanHuaYao() async =>
      tianGanHuaYaoFromContracts(await _port.getTianGanHuaYao());

  @override
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async =>
      diZhiHuaYaoFromContracts(await _port.getDiZhiHuaYao());

  @override
  Future<List<OthersHuaYao>> getOthersHuaYao() async =>
      othersHuaYaoFromContracts(await _port.getOthersHuaYao());
}

// ═══════════════════════════════════════════════════════
// Adapter: GeJu Repository
// ═══════════════════════════════════════════════════════

/// Wraps the contract-typed [IGeJuRepository] port and presents
/// product-typed methods (GeJuRule ↔ GeJuRuleContract, etc.)
class GeJuRepositoryAdapter implements GeJuProductRepository {
  final IGeJuRepository _port;
  GeJuRepositoryAdapter(this._port);

  // ── Rule ──

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

  // ── ConditionSet ──

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

  // ── Annotation ──

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

  // ── Preference ──

  @override
  Future<Map<String, dynamic>> getPreference() => _port.getPreference();

  @override
  Future<void> savePreference(Map<String, dynamic> pref) =>
      _port.savePreference(pref);

  // ── DeletionRecord ──

  @override
  Future<void> recordDeletion(Map<String, dynamic> record) =>
      _port.recordDeletion(record);

  // ── Cache ──

  @override
  void clearCache() => _port.clearCache();

  // ── Batch loading ──

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

  // ── Legacy ──

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async {
    final contracts = await _port.loadBuiltInRules();
    return contracts.map(geJuRuleFromContract).toList();
  }

  @override
  Future<List<GeJuRule>> loadUserRules() async {
    final contracts = await _port.loadUserRules();
    return contracts.map(geJuRuleFromContract).toList();
  }
}

// ═══════════════════════════════════════════════════════
// Adapter: GeJu School Service
// ═══════════════════════════════════════════════════════

/// Wraps [GeJuSchoolServicePort] (contract port) and presents
/// product-typed methods (GeJuSchool ↔ GeJuSchoolContract).
class GeJuSchoolServiceAdapter {
  final GeJuSchoolServicePort _port;
  GeJuSchoolServiceAdapter(this._port);

  Future<List<GeJuSchool>> getAllSchools() async {
    final contracts = await _port.getAllSchools();
    return contracts.map(geJuSchoolFromContract).toList();
  }

  Future<GeJuSchool?> getSchoolById(String id) async {
    final contract = await _port.getSchoolById(id);
    return contract != null ? geJuSchoolFromContract(contract) : null;
  }

  Future<GeJuSchool> createSchool({
    required String name,
    String? brief,
    List<String> features = const [],
  }) async {
    final contract =
        await _port.createSchool(name: name, brief: brief, features: features);
    return geJuSchoolFromContract(contract);
  }

  Future<void> updateSchool(GeJuSchool school) =>
      _port.updateSchool(geJuSchoolToContract(school));

  Future<void> deleteSchool(String id) => _port.deleteSchool(id);

  void clearCache() => _port.clearCache();
}
