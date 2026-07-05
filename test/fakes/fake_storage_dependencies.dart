// T-Q0-FAKE-01: Shared fake implementations of all QiZhengSiYuStorageDependencies ports.
//
// These fakes allow tests to construct fakeDeps without touching
// real databases, assets, or file I/O. Reused across Q0–Q6 tests.

import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart'
    hide GeJuBuiltInDataSource;
import 'package:qizhengsiyu/data/datasources/local/ge_ju_local_data_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';

// ===== IQiZhengSiYuPanRepository =====

class FakeQiZhengSiYuPanRepository implements IQiZhengSiYuPanRepository {
  final List<QiZhengSiYuPanContract> _store = [];

  int saveCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<void> save(QiZhengSiYuPanContract contract) async {
    saveCallCount++;
    _store.add(contract);
  }

  @override
  Future<QiZhengSiYuPanContract?> findByUuid(String uuid) async {
    try {
      return _store.firstWhere((c) => c.uuid == uuid && c.deletedAt == null);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> update(QiZhengSiYuPanContract contract) async {
    updateCallCount++;
    final idx = _store.indexWhere((c) => c.uuid == contract.uuid);
    if (idx >= 0) _store[idx] = contract;
  }

  @override
  Future<void> delete(String uuid) async {
    deleteCallCount++;
    _store.removeWhere((c) => c.uuid == uuid);
  }

  @override
  Future<void> permanentlyDelete(String uuid) async {
    _store.removeWhere((c) => c.uuid == uuid);
  }

  @override
  Future<List<QiZhengSiYuPanContract>> findAllActive() async =>
      _store.where((c) => c.deletedAt == null).toList();

  @override
  Future<List<QiZhengSiYuPanContract>> findByDivinationUuid(
      String divinationUuid) async =>
      _store.where((c) => c.divinationRequestInfoUuid == divinationUuid).toList();

  @override
  Future<List<QiZhengSiYuPanContract>> findByDateRange(
      DateTime startDate, DateTime endDate) async =>
      _store
          .where((c) =>
              c.createdAt.isAfter(startDate) && c.createdAt.isBefore(endDate))
          .toList();

  @override
  Future<PaginatedResult<QiZhengSiYuPanContract>> findWithPagination(
      {int page = 1, int pageSize = 20}) async {
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final items = _store.sublist(
        start, end > _store.length ? _store.length : end);
    return PaginatedResult(
      items: items,
      totalCount: _store.length,
      page: page,
      pageSize: pageSize,
      totalPages: (_store.length / pageSize).ceil(),
    );
  }

  @override
  Future<List<QiZhengSiYuPanContract>> search({
    String? divinationUuid,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    var results = _store.where((c) => c.deletedAt == null).toList();
    if (divinationUuid != null) {
      results = results
          .where((c) => c.divinationRequestInfoUuid == divinationUuid)
          .toList();
    }
    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    return results;
  }

  @override
  Future<int> getTotalCount() async => _store.length;

  @override
  Future<int> getTodayCount() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _store.where((c) => c.createdAt.isAfter(todayStart)).length;
  }

  @override
  Future<List<QiZhengSiYuPanContract>> getRecent({int limit = 10}) async {
    final sorted = List<QiZhengSiYuPanContract>.from(_store)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  @override
  Future<bool> existsByUuid(String uuid) async =>
      _store.any((c) => c.uuid == uuid);

  @override
  Future<void> saveBatch(List<QiZhengSiYuPanContract> contracts) async {
    _store.addAll(contracts);
  }

  @override
  Future<int> cleanupExpiredData({int daysOld = 30}) async => 0;
}

// ===== IGeJuRepository =====

class FakeGeJuRepository implements IGeJuRepository {
  final List<GeJuRuleContract> _rules = [];
  final Map<String, List<GeJuConditionSetContract>> _conditionSets = {};
  final Map<String, List<GeJuAnnotationContract>> _annotations = {};

  @override
  Future<List<GeJuRuleContract>> loadAllRules() async => List.from(_rules);

  @override
  Future<GeJuRuleContract?> getRuleById(String id) async {
    try {
      return _rules.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUserRule(GeJuRuleContract rule) async {
    _rules.removeWhere((r) => r.id == rule.id);
    _rules.add(rule);
  }

  @override
  Future<void> deleteUserRule(String id) async {
    _rules.removeWhere((r) => r.id == id);
  }

  @override
  bool isBuiltInRule(String ruleId) => false;

  @override
  Set<String> get builtInRuleIds => const {};

  @override
  Future<List<GeJuConditionSetContract>> getConditionSetsForRule(
      String ruleId) async =>
      _conditionSets[ruleId] ?? [];

  @override
  Future<GeJuConditionSetContract?> getConditionSetById(String id) async {
    for (final sets in _conditionSets.values) {
      try {
        return sets.firstWhere((s) => s.id == id);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> saveUserConditionSet(GeJuConditionSetContract cs) async {
    _conditionSets.putIfAbsent(cs.ruleId, () => []);
    _conditionSets[cs.ruleId]!.removeWhere((s) => s.id == cs.id);
    _conditionSets[cs.ruleId]!.add(cs);
  }

  @override
  Future<void> deleteUserConditionSet(String id) async {
    for (final key in _conditionSets.keys) {
      _conditionSets[key]!.removeWhere((s) => s.id == id);
    }
  }

  @override
  Future<void> deleteUserConditionSetsForRule(String ruleId) async {
    _conditionSets.remove(ruleId);
  }

  @override
  Future<List<GeJuAnnotationContract>> getAnnotationsForRule(
      String ruleId) async =>
      _annotations[ruleId] ?? [];

  @override
  Future<GeJuAnnotationContract?> getAnnotationById(String id) async {
    for (final anns in _annotations.values) {
      try {
        return anns.firstWhere((a) => a.id == id);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> saveUserAnnotation(GeJuAnnotationContract ann) async {
    _annotations.putIfAbsent(ann.ruleId, () => []);
    _annotations[ann.ruleId]!.removeWhere((a) => a.id == ann.id);
    _annotations[ann.ruleId]!.add(ann);
  }

  @override
  Future<void> deleteUserAnnotation(String id) async {
    for (final key in _annotations.keys) {
      _annotations[key]!.removeWhere((a) => a.id == id);
    }
  }

  @override
  Future<void> deleteUserAnnotationsForRule(String ruleId) async {
    _annotations.remove(ruleId);
  }

  @override
  Future<Map<String, dynamic>> getPreference() async => const {};

  @override
  Future<void> savePreference(Map<String, dynamic> pref) async {}

  @override
  Future<void> recordDeletion(Map<String, dynamic> record) async {}

  @override
  void clearCache() {}

  @override
  Future<Map<String, List<GeJuConditionSetContract>>>
      loadAllConditionSetsGrouped() async =>
          Map.from(_conditionSets);

  @override
  Future<Map<String, List<GeJuAnnotationContract>>>
      loadAllAnnotationsGrouped() async =>
          Map.from(_annotations);

  @override
  Future<List<GeJuRuleContract>> loadBuiltInRules() async => const [];

  @override
  Future<List<GeJuRuleContract>> loadUserRules() async => List.from(_rules);
}

// ===== GeJuBuiltInDataSource =====

class FakeGeJuBuiltInDataSource implements GeJuBuiltInDataSource {
  @override
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(
      String assetPath) async =>
      const [];

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async => const [];

  @override
  Future<List<GeJuAnnotation>> loadBuiltInAnnotations() async =>
      const [];

  @override
  Future<List<GeJuConditionSet>> loadBuiltInConditionSets() async =>
      const [];
}

// ===== GeJuSchoolServicePort =====

class FakeGeJuSchoolServicePort implements GeJuSchoolServicePort {
  final List<GeJuSchoolContract> _schools = [];

  @override
  Future<List<GeJuSchoolContract>> getAllSchools() async =>
      List.from(_schools);

  @override
  Future<GeJuSchoolContract?> getSchoolById(String id) async {
    try {
      return _schools.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<GeJuSchoolContract> createSchool({
    required String name,
    String? brief,
    List<String> features = const [],
  }) async {
    final school = GeJuSchoolContract(
      id: 'fake_${_schools.length}',
      name: name,
      brief: brief,
      features: features,
    );
    _schools.add(school);
    return school;
  }

  @override
  Future<void> updateSchool(GeJuSchoolContract school) async {
    final idx = _schools.indexWhere((s) => s.id == school.id);
    if (idx >= 0) _schools[idx] = school;
  }

  @override
  Future<void> deleteSchool(String id) async {
    _schools.removeWhere((s) => s.id == id);
  }

  @override
  void clearCache() {}
}

// ===== QiZhengShenShaRepository =====

class FakeQiZhengShenShaRepository implements QiZhengShenShaRepository {
  @override
  Future<List<ShenShaRecordContract>> getTianGanShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getYearDiZhiShenSha() async =>
      const [];

  @override
  Future<List<ShenShaRecordContract>> getMonthDiZhiShenSha() async =>
      const [];

  @override
  Future<List<ShenShaRecordContract>> getGanZhiShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getBundledShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getOtherShenSha() async => const [];
}

// ===== QiZhengHuaYaoRepository =====

class FakeQiZhengHuaYaoRepository implements QiZhengHuaYaoRepository {
  @override
  Future<List<HuaYaoRecordContract>> getTianGanHuaYao() async => const [];

  @override
  Future<List<HuaYaoRecordContract>> getDiZhiHuaYao() async => const [];

  @override
  Future<List<HuaYaoRecordContract>> getOthersHuaYao() async => const [];
}

// ===== QiZhengStarPositionStatusRepository =====

class FakeQiZhengStarPositionStatusRepository
    implements QiZhengStarPositionStatusRepository {
  @override
  Future<List<QiZhengStarPositionStatusContract>>
      loadStarPositionStatus() async =>
          const [];
}

// ===== QiZhengHistoricalEphemerisRepository =====

class FakeQiZhengHistoricalEphemerisRepository
    implements QiZhengHistoricalEphemerisRepository {
  @override
  Future<Map<String, dynamic>> loadHistoricalEphemeris() async =>
      const {};
}

// ===== QiZhengEphemerisResourceRepository =====

class FakeQiZhengEphemerisResourceRepository
    implements QiZhengEphemerisResourceRepository {
  @override
  Future<String> loadEphemerisResource(String resourceName) async => '';
}

// ===== QiZhengZhouTianModelRepository =====

class FakeQiZhengZhouTianModelRepository
    implements QiZhengZhouTianModelRepository {
  @override
  Future<List<QiZhengZhouTianModelContract>>
      loadBuiltInZhouTianModels() async =>
          const [];
}

// ===== QiZhengRecordRepository =====

class FakeQiZhengRecordRepository implements QiZhengRecordRepository {
  final List<QiZhengSiYuPanContract> _records = [];

  @override
  Future<String> saveRecord(QiZhengSiYuPanContract record) async {
    _records.removeWhere((r) => r.uuid == record.uuid);
    _records.add(record);
    return record.uuid;
  }

  @override
  Future<List<QiZhengSiYuPanContract>> getAllRecords() async {
    return List.from(_records);
  }

  @override
  Future<QiZhengSiYuPanContract?> getRecordByUuid(String uuid) async {
    try {
      return _records.firstWhere((r) => r.uuid == uuid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> softDeleteRecord(String uuid) async {
    final lengthBefore = _records.length;
    _records.removeWhere((r) => r.uuid == uuid);
    return _records.length < lengthBefore;
  }

  @override
  Stream<List<QiZhengSiYuPanContract>> watchAllRecords() {
    return Stream.value(List.from(_records));
  }
}
