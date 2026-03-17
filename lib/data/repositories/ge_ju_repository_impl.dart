import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/ge_ju_dao.dart';
import 'package:qizhengsiyu/data/datasources/local/ge_ju_legacy_migrator.dart';
import 'package:qizhengsiyu/data/datasources/local/ge_ju_local_data_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_deletion_record.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_user_preference.dart';
import 'package:qizhengsiyu/domain/errors/ge_ju_errors.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository.dart';

/// 格局仓库实现（三实体模型）
///
/// 在 Web 端，如果 Drift DB 不可用（缺少 sqlite3.wasm），
/// 会自动降级为只读模式，仅显示内置数据。
class GeJuRepositoryImpl implements IGeJuRepository {
  final GeJuBuiltInDataSource _builtInDataSource;
  final GeJuDao _dao;
  final GeJuLegacyMigrator _migrator;

  /// 内置规则缓存
  List<GeJuRule>? _builtInRulesCache;
  List<GeJuAnnotation>? _builtInAnnotationsCache;
  List<GeJuConditionSet>? _builtInConditionSetsCache;

  /// 按 ruleId 索引的缓存（O(1) 查找，由 _ensure* 方法构建）
  Map<String, List<GeJuConditionSet>>? _builtInConditionSetsByRuleId;
  Map<String, List<GeJuAnnotation>>? _builtInAnnotationsByRuleId;

  /// 内置规则 ID 集合
  final Set<String> _builtInRuleIds = {};

  /// 是否已完成迁移检查
  bool _migrationChecked = false;

  /// DB 是否可用（Web 端可能因缺少 WASM 文件而不可用）
  bool? _dbAvailable;

  GeJuRepositoryImpl({
    required GeJuBuiltInDataSource builtInDataSource,
    required GeJuDao dao,
  })  : _builtInDataSource = builtInDataSource,
        _dao = dao,
        _migrator = GeJuLegacyMigrator(dao: dao);

  // ══════════════════════════════════════════
  // Rule 操作
  // ══════════════════════════════════════════

  @override
  Future<List<GeJuRule>> loadAllRules() async {
    await _ensureMigrated();
    final builtIn = await _ensureBuiltInRulesLoaded();
    final userRules = await _queryDb(() => _dao.getAllRules(), <GeJuRule>[]);
    return [...builtIn, ...userRules];
  }

  @override
  Future<GeJuRule?> getRuleById(String id) async {
    // 先查内置
    final builtIn = await _ensureBuiltInRulesLoaded();
    for (final rule in builtIn) {
      if (rule.id == id) return rule;
    }
    // 再查用户库
    return await _queryDb(() => _dao.getRuleById(id), null);
  }

  @override
  Future<void> saveUserRule(GeJuRule rule) async {
    _requireDb();
    if (isBuiltInRule(rule.id)) {
      throw BuiltInRuleModificationError(rule.id);
    }
    await _dao.insertRule(rule);
  }

  @override
  Future<void> deleteUserRule(String id) async {
    _requireDb();
    if (isBuiltInRule(id)) {
      throw BuiltInRuleModificationError(id);
    }
    await _dao.deleteRule(id);
  }

  @override
  bool isBuiltInRule(String ruleId) {
    return _builtInRuleIds.contains(ruleId);
  }

  @override
  Set<String> get builtInRuleIds => Set.unmodifiable(_builtInRuleIds);

  // ══════════════════════════════════════════
  // ConditionSet 操作
  // ══════════════════════════════════════════

  @override
  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId) async {
    await _ensureBuiltInConditionSetsLoaded();
    final builtIn = _builtInConditionSetsByRuleId?[ruleId] ?? [];
    final user = await _queryDb(
        () => _dao.getConditionSetsForRule(ruleId), <GeJuConditionSet>[]);
    return [...builtIn, ...user];
  }

  @override
  Future<GeJuConditionSet?> getConditionSetById(String id) async {
    // 先查内置
    final builtInAll = await _ensureBuiltInConditionSetsLoaded();
    for (final cs in builtInAll) {
      if (cs.id == id) return cs;
    }
    // 再查用户库
    return await _queryDb(() => _dao.getConditionSetById(id), null);
  }

  @override
  Future<void> saveUserConditionSet(GeJuConditionSet cs) async {
    _requireDb();
    if (cs.isBuiltIn) {
      throw BuiltInRuleModificationError(cs.id);
    }
    await _dao.insertConditionSet(cs);
  }

  @override
  Future<void> deleteUserConditionSet(String id) async {
    _requireDb();
    await _dao.deleteConditionSet(id);
  }

  @override
  Future<void> deleteUserConditionSetsForRule(String ruleId) async {
    _requireDb();
    await _dao.deleteConditionSetsForRule(ruleId);
  }

  // ══════════════════════════════════════════
  // Annotation 操作
  // ══════════════════════════════════════════

  @override
  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId) async {
    await _ensureBuiltInAnnotationsLoaded();
    final builtIn = _builtInAnnotationsByRuleId?[ruleId] ?? [];
    final user = await _queryDb(
        () => _dao.getAnnotationsForRule(ruleId), <GeJuAnnotation>[]);
    return [...builtIn, ...user];
  }

  @override
  Future<GeJuAnnotation?> getAnnotationById(String id) async {
    // 先查内置
    final builtInAll = await _ensureBuiltInAnnotationsLoaded();
    for (final ann in builtInAll) {
      if (ann.id == id) return ann;
    }
    // 再查用户库
    return await _queryDb(() => _dao.getAnnotationById(id), null);
  }

  @override
  Future<void> saveUserAnnotation(GeJuAnnotation ann) async {
    _requireDb();
    if (ann.isBuiltIn) {
      throw BuiltInRuleModificationError(ann.id);
    }
    await _dao.insertAnnotation(ann);
  }

  @override
  Future<void> deleteUserAnnotation(String id) async {
    _requireDb();
    await _dao.deleteAnnotation(id);
  }

  @override
  Future<void> deleteUserAnnotationsForRule(String ruleId) async {
    _requireDb();
    await _dao.deleteAnnotationsForRule(ruleId);
  }

  // ══════════════════════════════════════════
  // Preference
  // ══════════════════════════════════════════

  @override
  Future<GeJuUserPreference> getPreference() async {
    return await _queryDb(
        () => _dao.getPreference(), GeJuUserPreference.defaultPreference);
  }

  @override
  Future<void> savePreference(GeJuUserPreference pref) async {
    _requireDb();
    await _dao.savePreference(pref);
  }

  // ══════════════════════════════════════════
  // DeletionRecord
  // ══════════════════════════════════════════

  @override
  Future<void> recordDeletion(GeJuDeletionRecord record) async {
    _requireDb();
    await _dao.insertDeletionRecord(record);
  }

  // ══════════════════════════════════════════
  // Cache
  // ══════════════════════════════════════════

  @override
  void clearCache() {
    _builtInRulesCache = null;
    _builtInAnnotationsCache = null;
    _builtInConditionSetsCache = null;
    _builtInConditionSetsByRuleId = null;
    _builtInAnnotationsByRuleId = null;
  }

  // ══════════════════════════════════════════
  // Legacy 兼容
  // ══════════════════════════════════════════

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async {
    return await _ensureBuiltInRulesLoaded();
  }

  @override
  Future<List<GeJuRule>> loadUserRules() async {
    return await _queryDb(() => _dao.getAllRules(), <GeJuRule>[]);
  }

  // ══════════════════════════════════════════
  // Internal helpers
  // ══════════════════════════════════════════

  /// 安全查询 DB，如果 DB 不可用则返回 fallback
  ///
  /// 首次调用时会尝试一次 DB 操作来探测可用性，
  /// 之后会缓存结果，避免重复失败。
  Future<T> _queryDb<T>(Future<T> Function() query, T fallback) async {
    if (_dbAvailable == false) return fallback;

    try {
      final result = await query();
      _dbAvailable = true;
      return result;
    } catch (e) {
      if (_dbAvailable == null) {
        // 首次探测失败，标记 DB 不可用
        _dbAvailable = false;
        debugPrint('GeJu DB not available (read-only mode): $e');
      }
      return fallback;
    }
  }

  /// 写操作前检查 DB 可用性，不可用时抛出友好错误
  void _requireDb() {
    if (_dbAvailable == false) {
      throw RuleStorageError('数据库不可用，无法执行写操作',
          details: 'Web 端需要配置 sqlite3.wasm 才能使用用户数据功能');
    }
  }

  /// 确保旧格式用户规则已迁移到 Drift DB（首次调用时执行）
  Future<void> _ensureMigrated() async {
    if (_migrationChecked) return;
    _migrationChecked = true;
    if (_dbAvailable != false) {
      await _migrator.migrateIfNeeded();
    }
  }

  Future<List<GeJuRule>> _ensureBuiltInRulesLoaded() async {
    if (_builtInRulesCache != null) return _builtInRulesCache!;
    _builtInRulesCache = await _builtInDataSource.loadBuiltInRules();
    _builtInRuleIds.clear();
    for (final rule in _builtInRulesCache!) {
      _builtInRuleIds.add(rule.id);
    }
    return _builtInRulesCache!;
  }

  Future<List<GeJuAnnotation>> _ensureBuiltInAnnotationsLoaded() async {
    if (_builtInAnnotationsCache != null) return _builtInAnnotationsCache!;
    _builtInAnnotationsCache = await _builtInDataSource.loadBuiltInAnnotations();
    // 构建 ruleId 索引
    final index = <String, List<GeJuAnnotation>>{};
    for (final ann in _builtInAnnotationsCache!) {
      index.putIfAbsent(ann.ruleId, () => []).add(ann);
    }
    _builtInAnnotationsByRuleId = index;
    return _builtInAnnotationsCache!;
  }

  Future<List<GeJuConditionSet>> _ensureBuiltInConditionSetsLoaded() async {
    if (_builtInConditionSetsCache != null) return _builtInConditionSetsCache!;
    _builtInConditionSetsCache = await _builtInDataSource.loadBuiltInConditionSets();
    // 构建 ruleId 索引
    final index = <String, List<GeJuConditionSet>>{};
    for (final cs in _builtInConditionSetsCache!) {
      index.putIfAbsent(cs.ruleId, () => []).add(cs);
    }
    _builtInConditionSetsByRuleId = index;
    return _builtInConditionSetsCache!;
  }

  // ══════════════════════════════════════════
  // Batch loading (评估管线优化)
  // ══════════════════════════════════════════

  @override
  Future<Map<String, List<GeJuConditionSet>>> loadAllConditionSetsGrouped() async {
    await _ensureBuiltInConditionSetsLoaded();
    final result = <String, List<GeJuConditionSet>>{};
    // 复制 built-in 索引
    _builtInConditionSetsByRuleId?.forEach((ruleId, list) {
      result[ruleId] = [...list];
    });
    // 合并 user 数据
    final userAll = await _queryDb(() => _dao.getAllConditionSets(), <GeJuConditionSet>[]);
    for (final cs in userAll) {
      result.putIfAbsent(cs.ruleId, () => []).add(cs);
    }
    return result;
  }

  @override
  Future<Map<String, List<GeJuAnnotation>>> loadAllAnnotationsGrouped() async {
    await _ensureBuiltInAnnotationsLoaded();
    final result = <String, List<GeJuAnnotation>>{};
    // 复制 built-in 索引
    _builtInAnnotationsByRuleId?.forEach((ruleId, list) {
      result[ruleId] = [...list];
    });
    // 合并 user 数据
    final userAll = await _queryDb(() => _dao.getAllAnnotations(), <GeJuAnnotation>[]);
    for (final ann in userAll) {
      result.putIfAbsent(ann.ruleId, () => []).add(ann);
    }
    return result;
  }
}
