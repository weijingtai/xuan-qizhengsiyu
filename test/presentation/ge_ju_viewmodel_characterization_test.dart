// T-Q0-GEJU-01: GeJu ViewModel characterization tests.
//
// Captures GeJuListViewModel behavior as a frozen baseline:
// initial state, loadRules, filtering, error handling.

import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository_adapter.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_crud_service.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_list_viewmodel.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

// ===== Fakes =====

class _FakeGeJuRepo implements IGeJuRepository {
  final List<GeJuRuleContract> rules;
  _FakeGeJuRepo({this.rules = const []});

  @override
  Future<List<GeJuRuleContract>> loadAllRules() async => rules;
  @override
  Future<GeJuRuleContract?> getRuleById(String id) async =>
      rules.where((r) => r.id == id).firstOrNull;
  @override
  Future<void> saveUserRule(GeJuRuleContract rule) async {}
  @override
  Future<void> deleteUserRule(String id) async {}
  @override
  bool isBuiltInRule(String ruleId) => ruleId.startsWith('builtin_');
  @override
  Set<String> get builtInRuleIds =>
      rules.where((r) => r.id.startsWith('builtin_')).map((r) => r.id).toSet();
  @override
  Future<List<GeJuConditionSetContract>> getConditionSetsForRule(String ruleId) async => const [];
  @override
  Future<GeJuConditionSetContract?> getConditionSetById(String id) async => null;
  @override
  Future<void> saveUserConditionSet(GeJuConditionSetContract cs) async {}
  @override
  Future<void> deleteUserConditionSet(String id) async {}
  @override
  Future<void> deleteUserConditionSetsForRule(String ruleId) async {}
  @override
  Future<List<GeJuAnnotationContract>> getAnnotationsForRule(String ruleId) async => const [];
  @override
  Future<GeJuAnnotationContract?> getAnnotationById(String id) async => null;
  @override
  Future<void> saveUserAnnotation(GeJuAnnotationContract ann) async {}
  @override
  Future<void> deleteUserAnnotation(String id) async {}
  @override
  Future<void> deleteUserAnnotationsForRule(String ruleId) async {}
  @override
  Future<Map<String, dynamic>> getPreference() async => const {};
  @override
  Future<void> savePreference(Map<String, dynamic> pref) async {}
  @override
  Future<void> recordDeletion(Map<String, dynamic> record) async {}
  @override
  void clearCache() {}
  @override
  Future<Map<String, List<GeJuConditionSetContract>>> loadAllConditionSetsGrouped() async => const {};
  @override
  Future<Map<String, List<GeJuAnnotationContract>>> loadAllAnnotationsGrouped() async => const {};
  @override
  Future<List<GeJuRuleContract>> loadBuiltInRules() async =>
      rules.where((r) => r.id.startsWith('builtin_')).toList();
  @override
  Future<List<GeJuRuleContract>> loadUserRules() async =>
      rules.where((r) => !r.id.startsWith('builtin_')).toList();
}

/// Repo that throws on loadAllRules for error path testing.
class _ThrowingGeJuRepo implements IGeJuRepository {
  @override
  Future<List<GeJuRuleContract>> loadAllRules() async =>
      throw Exception('Simulated load failure');
  @override
  Future<GeJuRuleContract?> getRuleById(String id) async => null;
  @override
  Future<void> saveUserRule(GeJuRuleContract rule) async {}
  @override
  Future<void> deleteUserRule(String id) async {}
  @override
  bool isBuiltInRule(String ruleId) => false;
  @override
  Set<String> get builtInRuleIds => const {};
  @override
  Future<List<GeJuConditionSetContract>> getConditionSetsForRule(String ruleId) async => const [];
  @override
  Future<GeJuConditionSetContract?> getConditionSetById(String id) async => null;
  @override
  Future<void> saveUserConditionSet(GeJuConditionSetContract cs) async {}
  @override
  Future<void> deleteUserConditionSet(String id) async {}
  @override
  Future<void> deleteUserConditionSetsForRule(String ruleId) async {}
  @override
  Future<List<GeJuAnnotationContract>> getAnnotationsForRule(String ruleId) async => const [];
  @override
  Future<GeJuAnnotationContract?> getAnnotationById(String id) async => null;
  @override
  Future<void> saveUserAnnotation(GeJuAnnotationContract ann) async {}
  @override
  Future<void> deleteUserAnnotation(String id) async {}
  @override
  Future<void> deleteUserAnnotationsForRule(String ruleId) async {}
  @override
  Future<Map<String, dynamic>> getPreference() async => const {};
  @override
  Future<void> savePreference(Map<String, dynamic> pref) async {}
  @override
  Future<void> recordDeletion(Map<String, dynamic> record) async {}
  @override
  void clearCache() {}
  @override
  Future<Map<String, List<GeJuConditionSetContract>>> loadAllConditionSetsGrouped() async => const {};
  @override
  Future<Map<String, List<GeJuAnnotationContract>>> loadAllAnnotationsGrouped() async => const {};
  @override
  Future<List<GeJuRuleContract>> loadBuiltInRules() async => const [];
  @override
  Future<List<GeJuRuleContract>> loadUserRules() async => const [];
}

GeJuRuleContract _makeRule(String id, String name) =>
    GeJuRuleContract(id: id, name: name, raw: {'id': id, 'name': name});

void main() {
  group('GeJuListViewModel Characterization (T-Q0-GEJU-01)', () {
    late GeJuListViewModel vm;
    late GeJuCrudService crudService;

    setUp(() {
      final repo = _FakeGeJuRepo(rules: [
        _makeRule('builtin_1', 'Rule A'),
        _makeRule('builtin_2', 'Rule B'),
        _makeRule('user_1', 'User Rule'),
      ]);
      final adapter = GeJuRepositoryAdapter(repo);
      crudService = GeJuCrudService(repository: adapter);
      vm = GeJuListViewModel(crudService: crudService);
    });

    test('initial state is empty and not loading', () {
      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNull);
      expect(vm.rules, isEmpty);
      expect(vm.totalCount, 0);
      expect(vm.searchKeyword, isEmpty);
      expect(vm.hasActiveFilters, isFalse);
    });

    test('loadRules populates rules from service', () async {
      await vm.loadRules();

      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNull);
      expect(vm.rules, isNotEmpty);
      expect(vm.totalCount, 3);
    });

    test('loadRules counts built-in vs user rules', () async {
      await vm.loadRules();

      expect(vm.builtInCount, 2);
      expect(vm.userCount, 1);
    });

    test('loadRules handles error from service', () async {
      final badAdapter = GeJuRepositoryAdapter(_ThrowingGeJuRepo());
      final badCrud = GeJuCrudService(repository: badAdapter);
      final badVm = GeJuListViewModel(crudService: badCrud);

      await badVm.loadRules();

      expect(badVm.isLoading, isFalse);
      expect(badVm.errorMessage, isNotNull);
      expect(badVm.rules, isEmpty);
    });

    test('dispose does not throw', () {
      expect(() => vm.dispose(), returnsNormally);
    });

    test('notifies listeners on loadRules', () async {
      var notifyCount = 0;
      vm.addListener(() => notifyCount++);

      await vm.loadRules();

      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });
}
