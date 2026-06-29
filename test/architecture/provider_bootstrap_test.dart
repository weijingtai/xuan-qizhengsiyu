import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/di.dart';
import 'package:qizhengsiyu/qizhengsiyu_storage_dependencies.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart'
    hide GeJuBuiltInDataSource;
import 'package:qizhengsiyu/data/datasources/local/ge_ju_local_data_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_list_viewmodel.dart';

void main() {
  group('Provider Bootstrap Tests', () {
    late FakeQiZhengSiYuPanRepository fakePanRepository;
    late FakeGeJuRepository fakeGeJuRepository;
    late FakeGeJuBuiltInDataSource fakeGeJuBuiltInDataSource;
    late FakeGeJuSchoolServicePort fakeGeJuSchoolServicePort;
    late FakeQiZhengShenShaRepository fakeShenShaRepository;
    late FakeQiZhengHuaYaoRepository fakeHuaYaoRepository;
    late FakeQiZhengStarPositionStatusRepository fakeStarPositionStatus;
    late FakeQiZhengHistoricalEphemerisRepository fakeHistoricalEphemeris;
    late FakeQiZhengEphemerisResourceRepository fakeEphemerisResource;
    late FakeQiZhengZhouTianModelRepository fakeZhouTianModelRepository;
    late FakeQiZhengRecordRepository fakeRecordRepository;
    late QiZhengSiYuStorageDependencies fakeDeps;

    setUp(() {
      fakePanRepository = FakeQiZhengSiYuPanRepository();
      fakeGeJuRepository = FakeGeJuRepository();
      fakeGeJuBuiltInDataSource = FakeGeJuBuiltInDataSource();
      fakeGeJuSchoolServicePort = FakeGeJuSchoolServicePort();
      fakeShenShaRepository = FakeQiZhengShenShaRepository();
      fakeHuaYaoRepository = FakeQiZhengHuaYaoRepository();
      fakeStarPositionStatus = FakeQiZhengStarPositionStatusRepository();
      fakeHistoricalEphemeris = FakeQiZhengHistoricalEphemerisRepository();
      fakeEphemerisResource = FakeQiZhengEphemerisResourceRepository();
      fakeZhouTianModelRepository = FakeQiZhengZhouTianModelRepository();
      fakeRecordRepository = FakeQiZhengRecordRepository();

      fakeDeps = QiZhengSiYuStorageDependencies(
        panRepository: fakePanRepository,
        recordRepository: fakeRecordRepository,
        geJuRepository: fakeGeJuRepository,
        geJuBuiltInDataSource: fakeGeJuBuiltInDataSource,
        geJuSchoolService: fakeGeJuSchoolServicePort,
        shenSha: fakeShenShaRepository,
        huaYao: fakeHuaYaoRepository,
        starPositionStatus: fakeStarPositionStatus,
        historicalEphemeris: fakeHistoricalEphemeris,
        ephemerisResource: fakeEphemerisResource,
        zhouTianModelRepository: fakeZhouTianModelRepository,
      );
    });

    test('createProviders(fakeDeps) creates providers successfully', () {
      final providers = createProviders(fakeDeps);
      expect(providers, isNotEmpty);
      expect(providers.length, greaterThan(5));
    });

    testWidgets('Providers are accessible and share the same storage dependencies instance', (tester) async {
      final providers = createProviders(fakeDeps);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<QiZhengSiYuStorageDependencies>.value(value: fakeDeps),
            ...providers,
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Verify we can resolve dependencies without throwing
                final resolvedDeps = context.read<QiZhengSiYuStorageDependencies>();
                expect(resolvedDeps, same(fakeDeps));

                // Verify we can resolve adapters/viewmodels
                final resolvedPanVm = context.read<QiZhengSiYuViewModel>();
                expect(resolvedPanVm, isNotNull);

                final resolvedGeJuListVm = context.read<GeJuListViewModel>();
                expect(resolvedGeJuListVm, isNotNull);

                return const Scaffold(body: Text('Loaded'));
              },
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Loaded'), findsOneWidget);
    });
  });
}

class FakeQiZhengSiYuPanRepository implements IQiZhengSiYuPanRepository {
  @override
  Future<void> save(QiZhengSiYuPanContract contract) async {}

  @override
  Future<QiZhengSiYuPanContract?> findByUuid(String uuid) async => null;

  @override
  Future<void> update(QiZhengSiYuPanContract contract) async {}

  @override
  Future<void> delete(String uuid) async {}

  @override
  Future<void> permanentlyDelete(String uuid) async {}

  @override
  Future<List<QiZhengSiYuPanContract>> findAllActive() async => const [];

  @override
  Future<List<QiZhengSiYuPanContract>> findByDivinationUuid(String divinationUuid) async => const [];

  @override
  Future<List<QiZhengSiYuPanContract>> findByDateRange(DateTime startDate, DateTime endDate) async => const [];

  @override
  Future<PaginatedResult<QiZhengSiYuPanContract>> findWithPagination({int page = 1, int pageSize = 20}) async {
    return const PaginatedResult(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
      totalPages: 0,
    );
  }

  @override
  Future<List<QiZhengSiYuPanContract>> search({
    String? divinationUuid,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async => const [];

  @override
  Future<int> getTotalCount() async => 0;

  @override
  Future<int> getTodayCount() async => 0;

  @override
  Future<List<QiZhengSiYuPanContract>> getRecent({int limit = 10}) async => const [];

  @override
  Future<bool> existsByUuid(String uuid) async => false;

  @override
  Future<void> saveBatch(List<QiZhengSiYuPanContract> contracts) async {}

  @override
  Future<int> cleanupExpiredData({int daysOld = 30}) async => 0;
}

class FakeGeJuRepository implements IGeJuRepository {
  @override
  Future<List<GeJuRuleContract>> loadAllRules() async => const [];

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

class FakeGeJuBuiltInDataSource implements GeJuBuiltInDataSource {
  @override
  Future<List<Map<String, dynamic>>> loadJsonFromAsset(String assetPath) async => const [];

  @override
  Future<List<GeJuRule>> loadBuiltInRules() async => const [];

  @override
  Future<List<GeJuAnnotation>> loadBuiltInAnnotations() async => const [];

  @override
  Future<List<GeJuConditionSet>> loadBuiltInConditionSets() async => const [];
}

class FakeGeJuSchoolServicePort implements GeJuSchoolServicePort {
  @override
  Future<List<GeJuSchoolContract>> getAllSchools() async => const [];

  @override
  Future<GeJuSchoolContract?> getSchoolById(String id) async => null;

  @override
  Future<GeJuSchoolContract> createSchool({
    required String name,
    String? brief,
    List<String> features = const [],
  }) async {
    return GeJuSchoolContract(id: 'fake', name: name, brief: brief, features: features);
  }

  @override
  Future<void> updateSchool(GeJuSchoolContract school) async {}

  @override
  Future<void> deleteSchool(String id) async {}

  @override
  void clearCache() {}
}

class FakeQiZhengShenShaRepository implements QiZhengShenShaRepository {
  @override
  Future<List<ShenShaRecordContract>> getTianGanShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getYearDiZhiShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getMonthDiZhiShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getGanZhiShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getBundledShenSha() async => const [];

  @override
  Future<List<ShenShaRecordContract>> getOtherShenSha() async => const [];
}

class FakeQiZhengHuaYaoRepository implements QiZhengHuaYaoRepository {
  @override
  Future<List<HuaYaoRecordContract>> getTianGanHuaYao() async => const [];

  @override
  Future<List<HuaYaoRecordContract>> getDiZhiHuaYao() async => const [];

  @override
  Future<List<HuaYaoRecordContract>> getOthersHuaYao() async => const [];
}

class FakeQiZhengStarPositionStatusRepository implements QiZhengStarPositionStatusRepository {
  @override
  Future<List<QiZhengStarPositionStatusContract>> loadStarPositionStatus() async => const [];
}

class FakeQiZhengHistoricalEphemerisRepository implements QiZhengHistoricalEphemerisRepository {
  @override
  Future<Map<String, dynamic>> loadHistoricalEphemeris() async => const {};
}

class FakeQiZhengEphemerisResourceRepository implements QiZhengEphemerisResourceRepository {
  @override
  Future<String> loadEphemerisResource(String resourceName) async => '';
}

class FakeQiZhengZhouTianModelRepository implements QiZhengZhouTianModelRepository {
  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async => const [];
}

class FakeQiZhengRecordRepository implements QiZhengRecordRepository {
  @override
  Future<String> saveRecord(QiZhengSiYuPanContract record) async => record.uuid;

  @override
  Future<List<QiZhengSiYuPanContract>> getAllRecords() async => const [];

  @override
  Future<QiZhengSiYuPanContract?> getRecordByUuid(String uuid) async => null;

  @override
  Future<bool> softDeleteRecord(String uuid) async => true;

  @override
  Stream<List<QiZhengSiYuPanContract>> watchAllRecords() => Stream.value(const []);
}
